# frozen_string_literal: true

# Dummy implementation
class ClientApplication
  attr_accessor :key

  def self.find_by(key:)
    ClientApplication.new(key)
  end

  def self.find_by!(key:)
    ClientApplication.new(key)
  end

  def initialize(key)
    @key = key
  end

  def tokens
    @tokens ||= []
  end

  def secret
    'secret'
  end

  def callback_url
    'http://mysite.com/callback'
  end
end

class OauthToken
  attr_accessor :token, :refresh_token

  def self.where(_q, p)
    case p
    when 'not_authorized', 'invalidated'
      []
    else
      [OauthToken.new(p)]
    end
  end

  def self.create(*)
    OauthToken.new('token')
  end

  def initialize(token)
    @token = token
  end

  def secret
    'secret'
  end
end

class Oauth2Token < OauthToken; end
class Oauth2Verifier < OauthToken; end
class AccessToken < OauthToken; end
class RequestToken < OauthToken; end

class OauthNonce
  # Always remember
  def self.remember(_nonce, _timestamp)
    true
  end
end
