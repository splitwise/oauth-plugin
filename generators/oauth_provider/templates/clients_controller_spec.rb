require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/oauth_controller_spec_helper'
require 'oauth/client/action_controller_request'

describe OauthClientsController do
  if defined?(Devise)
    include Devise::TestHelpers
  end
  include OAuthControllerSpecHelper
  fixtures :client_applications, :oauth_tokens, :users
  before(:each) do
    login_as_application_owner
  end

  describe "index" do
    before do
      @client_applications = @user.client_applications
    end

    def do_get
      get :index
    end

    it "should be successful" do
      do_get
      expect(response).to be_success
    end

    it "should assign client_applications" do
      do_get
      assigns[:client_applications].should==@client_applications
    end

    it "should render index template" do
      do_get
      expect(response).to render_template('index')
    end
  end

  describe "show" do

    def do_get
      get :show, :id => '1'
    end

    it "should be successful" do
      do_get
      expect(response).to be_success
    end

    it "should assign client_applications" do
      do_get
      expect(assigns[:client_application]).to eq(current_client_application)
    end

    it "should render show template" do
      do_get
      expect(response).to render_template('show')
    end

  end

  describe "new" do

    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      expect(response).to be_success
    end

    it "should assign client_applications" do
      do_get
      expect(assigns[:client_application].class).to eq(ClientApplication)
    end

    it "should render show template" do
      do_get
      expect(response).to render_template('new')
    end

  end

  describe "edit" do
    def do_get
      get :edit, :id => '1'
    end

    it "should be successful" do
      do_get
      expect(response).to be_success
    end

    it "should assign client_applications" do
      do_get
      expect(assigns[:client_application]).to eq(current_client_application)
    end

    it "should render edit template" do
      do_get
      expect(response).to render_template('edit')
    end

  end

  describe "create" do

    def do_valid_post
      post :create, 'client_application' => {'name' => 'my site', :url => "http://test.com"}
      @client_application = ClientApplication.last
    end

    def do_invalid_post
      post :create
    end

    it "should redirect to new client_application" do
      do_valid_post
      expect(response).to be_redirect
      expect(response).to redirect_to(:action => "show", :id => @client_application.id)
    end

    it "should render show template" do
      do_invalid_post
      expect(response).to render_template('new')
    end
  end

  describe "destroy" do

    def do_delete
      delete :destroy, :id => '1'
    end

    it "should destroy client applications" do
      do_delete
      ClientApplication.should_not be_exists(1)
    end

    it "should redirect to list" do
      do_delete
      expect(response).to be_redirect
      expect(response).to redirect_to(:action => 'index')
    end

  end

  describe "update" do

    def do_valid_update
      put :update, :id => '1', 'client_application' => {'name' => 'updated site'}
    end

    def do_invalid_update
      put :update, :id => '1', 'client_application' => {'name' => nil}
    end

    it "should redirect to show client_application" do
      do_valid_update
      expect(response).to be_redirect
      expect(response).to redirect_to(:action => "show", :id => 1)
    end

    it "should assign client_applications" do
      do_invalid_update
      expect(assigns[:client_application]).to eq(ClientApplication.find(1))
    end

    it "should render show template" do
      do_invalid_update
      expect(response).to render_template('edit')
    end
  end
end
