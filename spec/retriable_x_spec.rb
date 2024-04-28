# frozen_string_literal: true

RSpec.describe RetriableX do
  it "has a version number" do
    expect(RetriableX::VERSION).not_to be nil
  end

  it "scope" do
    expect(RetriableX::Scope::TweetRead).to eq(:"tweet.read")
  end

  it "scopes" do
    expect(RetriableX::Scopes::FollowCheck).to eq([:"users.read", :"offline.access"])
  end

  it "client new" do
    expect(RetriableX::Oauth2Client::new("a", "b", "c")).not_to be nil
  end

  it "oauth url" do
    client = RetriableX::Oauth2Client::new("a", "b", "c")
    url, pkce, state = client.oauth_url(RetriableX::Scopes::FollowCheck)
    expect(url).not_to be nil
    expect(pkce).not_to be nil
    expect(state).not_to be nil
  end
end
