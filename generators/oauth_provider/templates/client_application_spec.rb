# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'
describe ClientApplication do
  fixtures :users, :client_applications, :oauth_tokens
  before(:each) do
    @application = described_class.create name: 'Agree2', url: 'http://agree2.com', user: users(:quentin)
  end

  it 'should be valid' do
    expect(@application).to be_valid
  end

  it 'should not have errors' do
    expect(@application.errors.full_messages).to eq([])
  end

  it 'should have key and secret' do
    expect(@application.key).not_to be_nil
    expect(@application.secret).not_to be_nil
  end

  it 'should have credentials' do
    expect(@application.credentials).not_to be_nil
    expect(@application.credentials.key).to eq(@application.key)
    expect(@application.credentials.secret).to eq(@application.secret)
  end
end
