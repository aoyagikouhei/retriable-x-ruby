# frozen_string_literal: true

require "json"
require "x"

module RetriableX
  # X Client
  class Client
    # @param access_token [String] OAuth2 access token
    # @param refresh_token [String] OAuth2 refresh token
    # @param client_key [String] OAuth2 client_key
    # @param client_secret [String] OAuth2 client_secret
    # @param consumer_key [String] OAuth1 consumer key
    # @param consumer_secret [String] OAuth1 consumer secret
    # @param access_key [String] OAuth1 access key
    # @param access_secret [String] OAuth1 access secret
    # @param try_count [Integer] try_count
    # @param retry_delay [Integer] retry delay seconds
    def initialize(**args)
      @args = args
      @try_count = @args[:try_count] || 1
      @retry_delay = @args[:retry_delay] || 0
      @client = make_client(@args)
    end

    def me
      execute do |_count|
        @client.get("users/me")
      end
    end

    def follow_check_screenname(screenname)
      res = execute do |_count|
        @client.get("users/by/username/#{screenname}?user.fields=connection_status")
      end
      follow?(res)
    end

    private

    def execute
      count = 1
      refreshed_flag = false
      loop do
        return yield(count)
      rescue StandardError => e
        count, refreshed_flag = check_err(e, count, refreshed_flag)
      end
    end

    def check_err(err, count, refreshed_flag)
      if err.is_a?(X::Unauthorized)
        raise err unless refresh? && !refreshed_flag

        refresh
        return [count, true]
      end
      raise err if @try_count <= count

      sleep @retry_delay if @retry_delay.positive?
      [count + 1, refreshed_flag]
    end

    def refresh?
      !@args[:refresh_token].nil? &&
        !@args[:client_key].nil? &&
        !@args[:client_secret].nil?
    end

    def refresh
      client = RetriableX::Oauth2Client.new(@args)
      token = client.refresh(@args[:refresh_token])
      @args[:refresh_token] = token.refresh_token
      @args[:access_token] = token.access_token
      @client = make_client(@args)
    end

    def follow?(src)
      connection_status = src.dig("data", "connection_status") || src.dig(:data, :connection_status) || []
      connection_status.include?("following")
    end

    def make_client(args)
      if !args[:api_key].nil?
        make_client_oauth1(args)
      elsif !args[:access_token].nil?
        X::Client.new(bearer_token: args[:access_token])
      else
        raise "OAuth key not found"
      end
    end

    def make_client_oauth1(args)
      X::Client.new(
        api_key: args[:consumer_key],
        api_key_secret: args[:consumer_secret],
        access_token: args[:access_key],
        access_token_secret: args[:access_secret]
      )
    end
  end
end
