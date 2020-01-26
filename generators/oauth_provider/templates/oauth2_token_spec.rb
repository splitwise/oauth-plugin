# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth2Token do
  fixtures :client_applications, :users, :oauth_tokens
  before(:each) do
    @token = described_class.create client_application: client_applications(:one), user: users(:aaron)
  end

  it 'is valid' do
    expect(@token).to be_valid
  end

  it 'haves a token' do
    @token.token.should_not be_nil
  end

  it 'haves a secret' do
    @token.secret.should_not be_nil
  end

  it 'is authorized' do
    expect(@token).to be_authorized
  end

  it 'is not invalidated' do
    @token.should_not be_invalidated
  end

  it 'generates correct json and query strong' do
    expect(@token.as_json).to eq(access_token: @token.token, token_type: 'bearer')
    expect(@token.to_query).to eq("access_token=#{@token.token}&token_type=bearer")
  end

  it 'generates correct json and query string and include state in query if present' do
    @token.state = 'bb bb'
    expect(@token.as_json).to eq(access_token: @token.token, token_type: 'bearer')
    expect(@token.to_query).to eq("access_token=#{@token.token}&token_type=bearer&state=bb%20bb")
  end

  it 'generates correct json and query string and include scope in query if present' do
    @token.scope = 'bbbb aaaa'
    expect(@token.as_json).to eq(access_token: @token.token, token_type: 'bearer')
    expect(@token.to_query).to eq("access_token=#{@token.token}&token_type=bearer&scope=bbbb%20aaaa")
  end

  it 'generates correct json and include expires_in if present' do
    @token.expires_at = 1.hour.from_now
    expect(@token.as_json).to eq(access_token: @token.token, token_type: 'bearer', expires_in: 3600)
    expect(@token.to_query).to eq("access_token=#{@token.token}&token_type=bearer&expires_in=3600")
  end
end
