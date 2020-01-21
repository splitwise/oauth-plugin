# frozen_string_literal: true

require 'spec_helper'
require 'oauth/controllers/provider_controller'
require 'oauth/controllers/application_controller_methods'
require 'dummy_provider_models'
require 'rack/test'
require 'action_pack'
require 'action_controller'

class OauthProviderController < ActionController::Base
  before_action :verify_authenticity_token
  def verify_authenticity_token; end

  include OAuth::Controllers::ApplicationControllerMethods
  include OAuth::Controllers::ProviderController

  def logger
    Logger.new(StringIO.new) # throwaway
  end
end

class User
  def self.authenticate(*)
    User.new
  end
end

describe OAuth::Controllers::ProviderController do
  include Rack::Test::Methods

  let(:app) { OauthProviderController.action(:token) }
  let(:base_params) { { 'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => grant_type } }
  let(:client_id) { 'client id' }
  let(:client_secret) { 'secret' }
  let(:grant_type) { 'password' }

  context 'with an invalid secret' do
    let(:client_secret) { 'invalid secret' }

    it 'errors out' do
      get '/', base_params
      expect(last_response).to have_attributes(
        status: 400,
        body: /invalid_client/
      )
    end
  end

  it 'allow omission of redirect_uri' do
    get '/', base_params
    expect(last_response.status).to eq(200)
  end

  context 'with a redirect_uri' do
    let(:params) { base_params.merge(redirect_uri: redirect_uri) }

    context 'when the redirect_uri param matches the app callback URL' do
      let(:redirect_uri) { ClientApplication.new(:x).callback_url }

      it 'authenticates successfully' do
        get '/', params
        expect(last_response.status).to eq(200)
      end
    end

    context 'when the redirect_uri param does not match the app callback URL' do
      let(:redirect_uri) { "#{ClientApplication.new(:x).callback_url}?a=b" }

      it 'returns an error' do
        get '/', params
        expect(last_response.status).to eq(400)
      end
    end
  end
end
