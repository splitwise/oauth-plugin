require File.dirname(__FILE__) + '/../spec_helper'
describe ClientApplication do
  fixtures :users, :client_applications, :oauth_tokens
  before(:each) do
    @application = ClientApplication.create :name => "Agree2", :url => "http://agree2.com", :user => users(:quentin)
  end

  it "should be valid" do
    expect(@application).to be_valid
  end


  it "should not have errors" do
    expect(@application.errors.full_messages).to eq([])
  end

  it "should have key and secret" do
    @application.key.should_not be_nil
    @application.secret.should_not be_nil
  end

  it "should have credentials" do
    @application.credentials.should_not be_nil
    expect(@application.credentials.key).to eq(@application.key)
    expect(@application.credentials.secret).to eq(@application.secret)
  end

end

