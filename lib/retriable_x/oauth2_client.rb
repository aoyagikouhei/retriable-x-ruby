# frozen_string_literal: true

require "twitter_oauth2"

module RetriableX
  # OAuth2 Client
  class Oauth2Client
    # @param client_key [String] OAuth2 client_key
    # @param client_secret [String] OAuth2 client_secret
    # @param redirect_uri [String] OAuth2 redirect_uri
    def initialize(**args)
      @args = args
      @client = TwitterOAuth2::Client.new(
        identifier: @args[:client_id],
        secret: @args[:client_secret],
        redirect_uri: @args[:redirect_uri] || ""
      )
    end

    def oauth_url(scopes)
      authorization_uri = @client.authorization_uri(scope: scopes)
      [authorization_uri, @client.code_verifier, @client.state]
    end

    def access_token!(code, code_verifier)
      @client.authorization_code = code
      @client.access_token! code_verifier
    end

    def refresh!(refresh_token)
      @client.refresh_token = refresh_token
      @client.access_token!
    end
  end
end
