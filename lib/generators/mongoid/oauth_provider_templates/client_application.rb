# frozen_string_literal: true

require 'oauth'

class ClientApplication
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,          type: String
  field :url,           type: String
  field :support_url,   type: String
  field :callback_url,  type: String
  field :key,           type: String
  field :secret,        type: String
  field :secret,        type: String

  index :key, unique: true

  referenced_in :user
  references_many :tokens, class_name: 'OauthToken'
  references_many :access_tokens
  references_many :oauth2_verifiers
  references_many :oauth_tokens

  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation :generate_keys, on: :create

  validates_format_of :url, with: %r{\Ahttp(s?)://(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(/|/([\w#!:.?+=&%@!\-/]))?}i
  validates_format_of :support_url, with: %r{\Ahttp(s?)://(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(/|/([\w#!:.?+=&%@!\-/]))?}i, allow_blank: true
  validates_format_of :callback_url, with: %r{\Ahttp(s?)://(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(/|/([\w#!:.?+=&%@!\-/]))?}i, allow_blank: true

  attr_accessor :token_callback_url

  def self.find_token(token_key)
    token = OauthToken.where(token: token_key)
    token if token&.authorized?
  end

  def self.verify_request(request, options = {}, &block)
    signature = OAuth::Signature.build(request, options, &block)
    unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      return false
    end

    value = signature.verify
    value
  rescue OAuth::Signature::UnknownSignatureMethod => e
    false
  end

  def oauth_server
    @oauth_server ||= OAuth::Server.new('http://your.site')
  end

  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  # If your application requires passing in extra parameters handle it here
  def create_request_token(_params = {})
    RequestToken.create client_application: self, callback_url: token_callback_url
  end

  protected

  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0, 40]
    self.secret = OAuth::Helper.generate_key(40)[0, 40]
  end
end
