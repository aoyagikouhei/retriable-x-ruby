# frozen_string_literal: true

require 'json'
require 'x'

module RetriableX
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
      @client = RetriableX::Client::make_client(@args)
    end

    def me()
      execute do |count|
        @client.get("users/me")
      end
    end

    def follow_check_screenname(screenname)
      res = execute do |count|
        @client.get("users/by/username/#{screenname}?user.fields=connection_status")
      end
      follow?(res)
    end

    def refresh(refresh_token)
      @client.refresh_token = refresh_token
      @client.access_token!
    end

    private

    def execute
      count = 1
      refreshed_flag = false
      loop do
        return yield(count)
      rescue => e
        if e.is_a?(X::Unauthorized)
          # try once refresh
          if is_refresh?() && !refreshed_flag
            refreshed_flag = true
            refresh()
            continue
          else
            raise e
          end
        end
        raise e if @try_count <= count
        count += 1
        sleep @retry_delay if @retry_delay > 0
      end
    end

    def is_refresh?
      !@args[:refresh_token].nil? &&
        !@args[:client_key].nil? &&
        !@args[:client_secret].nil?
    end

    def refresh
      client = RetriableX::Oauth2Client::new(@args[:client_key], @args[:client_secret], '')
      token = client.refresh(@args[:refresh_token])
      @args[:refresh_token] = token.refresh_token
      @args[:access_token] = token.access_token
      @client = make_client(@args)
    end

    def follow?(src)
      connection_status = src.dig("data", "connection_status") || src.dig(:data, :connection_status) || []
      connection_status.include?("following")
    end

    def self.make_client(args)
      if !args[:api_key].nil?
        X::Client.new(
          api_key: args[:consumer_key],
          api_key_secret: args[:consumer_secret],
          access_token: args[:access_key],
          access_token_secret: args[:access_secret] )
      elsif !args[:access_token].nil?
        X::Client.new(bearer_token: args[:access_token])
      else
        raise "OAuth key not found"
      end
    end
  end
end


