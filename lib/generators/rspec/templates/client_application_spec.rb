# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'
describe ClientApplication do
  fixtures :users, :client_applications, :oauth_tokens
  before(:each) do
    @application = described_class.create name: 'Agree2', url: 'http://agree2.com', user: users(:quentin)
  end

  it 'is valid' do
    expect(@application).to be_valid
  end

  it 'does not have errors' do
    expect(@application.errors.full_messages).to eq([])
  end

  it 'has key and secret' do
    @application.key.should_not be_nil
    @application.secret.should_not be_nil
  end

  it 'has credentials' do
    @application.credentials.should_not be_nil
    expect(@application.credentials.key).to eq(@application.key)
    expect(@application.credentials.secret).to eq(@application.secret)
  end
end
