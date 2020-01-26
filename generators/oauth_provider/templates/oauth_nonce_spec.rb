# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'
require 'oauth/helper'
describe OauthNonce do
  include OAuth::Helper
  before(:each) do
    @oauth_nonce = described_class.remember(generate_key, Time.now.to_i)
  end

  it 'is valid' do
    expect(@oauth_nonce).to be_valid
  end

  it 'does not have errors' do
    expect(@oauth_nonce.errors.full_messages).to eq([])
  end

  it 'does not be a new record' do
    @oauth_nonce.should_not be_new_record
  end

  it 'does not allow a second one with the same values' do
    expect(described_class.remember(@oauth_nonce.nonce, @oauth_nonce.timestamp)).to eq(false)
  end
end
