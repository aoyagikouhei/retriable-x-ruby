# frozen_string_literal: true

RSpec.describe RetriableX do
  it "has a version number" do
    expect(RetriableX::VERSION).not_to be nil
  end

  it "scope" do
    expect(RetriableX::Scope::TweetRead).to eq(:"tweet.read")
  end

  it "scopes" do
    expect(RetriableX::Scopes::FollowCheck).to eq([:"tweet.read", :"users.read", :"offline.access"])
  end

  it "oauth client new" do
    expect(RetriableX::Oauth2Client::new("a", "b", "c")).not_to be nil
  end

  it "oauth url" do
    client = RetriableX::Oauth2Client::new("a", "b", "c")
    url, pkce, state = client.oauth_url(RetriableX::Scopes::FollowCheck)
    expect(url).not_to be nil
    expect(pkce).not_to be nil
    expect(state).not_to be nil
  end

  it "client new" do
    expect(RetriableX::Client::new(access_token: 'a')).not_to be nil
  end

  it "client me error" do
    client = RetriableX::Client::new(access_token: 'a')
    expect{client.me()}.to raise_error(X::Forbidden)
  end

  it "client follow_check_screenname error" do
    client = RetriableX::Client::new(access_token: 'a')
    expect{client.follow_check_screenname('aoyagikouhei')}.to raise_error(X::Unauthorized)
  end

  it "client follow?" do
    client = RetriableX::Client::new(access_token: 'a')
    expect(client.send(:follow?, {})).to be false
    data = {"data": {
      "connection_status": ["following"]
    }}
    expect(client.send(:follow?, data)).to be true
  end
end
