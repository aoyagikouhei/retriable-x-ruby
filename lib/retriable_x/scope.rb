# frozen_string_literal: true

module RetriableX
  module Scope
    TWEET_READ = :"tweet.read"
    TWEET_WRITE = :"tweet.write"
    TWEET_MODERATE_WRITE = :"tweet.moderate.write"
    USERS_READ = :"users.read"
    FOLLOWS_READ = :"follows.read"
    FOLLOWS_WRITE = :"follows.write"
    OFFLINE_ACCESS = :"offline.access"
    SPACE_READ = :"space.read"
    MUTE_READ = :"mute.read"
    MUTE_WRITE = :"mute.write"
    LIKE_READ = :"like.read"
    LIKE_WRITE = :"like.write"
    LIST_READ = :"list.read"
    LIST_WRITE = :"list.write"
    BLOCK_READ = :"block.read"
    BLOCK_WRITE = :"block.write"
    BOOKMARK_READ = :"bookmark.read"
    BOOKMARK_WRITE = :"bookmark.write"
    DM_READ = :"dm.read"
    DM_WRITE = :"dm.write"
  end

  module Scopes
    FOLLOW_CHECK = [RetriableX::Scope::TWEET_READ, RetriableX::Scope::USERS_READ,
                    RetriableX::Scope::OFFLINE_ACCESS].freeze
  end
end
