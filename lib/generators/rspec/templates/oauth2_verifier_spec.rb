# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth2Verifier do
  fixtures :client_applications, :users, :oauth_tokens
  before(:each) do
    @verifier = described_class.create client_application: client_applications(:one), user: users(:aaron), scope: 'bbbb aaaa'
  end

  it 'is valid' do
    expect(@verifier).to be_valid
  end

  it 'has a code' do
    @verifier.code.should_not be_nil
  end

  it 'does not have a secret' do
    expect(@verifier.secret).to be_nil
  end

  it 'is authorized' do
    expect(@verifier).to be_authorized
  end

  it 'is not invalidated' do
    @verifier.should_not be_invalidated
  end

  it 'generates query string' do
    expect(@verifier.to_query).to eq("code=#{@verifier.code}")
    @verifier.state = 'bbbb aaaa'
    expect(@verifier.to_query).to eq("code=#{@verifier.code}&state=bbbb%20aaaa")
  end

  it 'properly exchanges for token' do
    @token = @verifier.exchange!
    expect(@verifier).to be_invalidated
    @token.user.should == @verifier.user
    expect(@token.client_application).to eq(@verifier.client_application)
    expect(@token).to be_authorized
    @token.should_not be_invalidated
    expect(@token.scope).to eq(@verifier.scope)
  end
end
