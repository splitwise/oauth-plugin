# frozen_string_literal: true

require 'spec_helper'
require 'multi_json'
require 'oauth/provider/authorizer'
require 'dummy_provider_models'

describe OAuth::Provider::Authorizer do
  describe 'Authorization code' do
    describe 'should issue code' do
      before(:each) do
        @user = double('user')
        @app  = double('app')
        @code = double('code', token: 'secret auth code')

        expect(::ClientApplication).to receive(:find_by!).with(key: 'client id').and_return(@app)
        allow(@app).to receive(:callback_url).and_return('http://mysite.com/callback')
      end

      it 'allows' do
        expect(::Oauth2Verifier).to receive(:create!).with(client_application: @app,
                                                           user: @user,
                                                           callback_url: 'http://mysite.com/callback',
                                                           scope: 'a b').and_return(@code)

        @authorizer = described_class.new @user, true, response_type: 'code',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback'

        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?code=secret%20auth%20code')
        expect(@authorizer).to be_authorized
      end

      it 'includes state' do
        expect(::Oauth2Verifier).to receive(:create!).with(client_application: @app,
                                                           user: @user,
                                                           callback_url: 'http://mysite.com/callback',
                                                           scope: 'a b').and_return(@code)

        @authorizer = described_class.new @user, true, response_type: 'code',
                                                       state: 'customer id',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback'

        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?code=secret%20auth%20code&state=customer%20id')
        expect(@authorizer).to be_authorized
      end

      it 'allows query string in callback' do
        expect(::Oauth2Verifier).to receive(:create!).with(client_application: @app,
                                                           user: @user,
                                                           callback_url: 'http://mysite.com/callback?this=one',
                                                           scope: 'a b').and_return(@code)

        allow(@app).to receive(:callback_url).and_return('http://mysite.com/callback?this=one')
        @authorizer = described_class.new @user, true, response_type: 'code',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback?this=one'
        expect(@authorizer).to be_authorized
        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?this=one&code=secret%20auth%20code')
      end
    end
  end

  describe 'user does not authorize' do
    it 'sends error' do
      @authorizer = described_class.new @user, false, response_type: 'code',
                                                      scope: 'a b',
                                                      client_id: 'client id',
                                                      redirect_uri: 'http://mysite.com/callback'

      expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?error=access_denied')
      expect(@authorizer).not_to be_authorized
    end

    it 'sends error with state and query params in callback' do
      app = instance_double('ClientApplication')
      allow(::ClientApplication).to receive(:find_by!).and_return(app)
      allow(app).to receive(:callback_url).and_return('http://mysite.com/callback?this=one')

      @authorizer = described_class.new @user, false, response_type: 'code',
                                                      scope: 'a b',
                                                      client_id: 'client id',
                                                      redirect_uri: 'http://mysite.com/callback?this=one',
                                                      state: 'my customer'

      expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?this=one&error=access_denied&state=my%20customer')
      expect(@authorizer).not_to be_authorized
    end
  end

  describe 'Implict Grant' do
    describe 'should issue token' do
      before(:each) do
        @user = double('user')
        @app  = double('app')
        @token = double('token', token: 'secret auth code')

        expect(::ClientApplication).to receive(:find_by!).with(key: 'client id').and_return(@app)
        allow(@app).to receive(:callback_url).and_return('http://mysite.com/callback')
      end

      it 'allows' do
        expect(::Oauth2Token).to receive(:create!).with(client_application: @app,
                                                        user: @user,
                                                        callback_url: 'http://mysite.com/callback',
                                                        scope: 'a b').and_return(@token)

        @authorizer = described_class.new @user, true, response_type: 'token',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback'

        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback#access_token=secret%20auth%20code')
        expect(@authorizer).to be_authorized
      end

      it 'includes state' do
        expect(::Oauth2Token).to receive(:create!).with(client_application: @app,
                                                        user: @user,
                                                        callback_url: 'http://mysite.com/callback',
                                                        scope: 'a b').and_return(@token)

        @authorizer = described_class.new @user, true, response_type: 'token',
                                                       state: 'customer id',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback'

        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback#access_token=secret%20auth%20code&state=customer%20id')
        expect(@authorizer).to be_authorized
      end

      it 'allows query string in callback' do
        allow(@app).to receive(:callback_url).and_return('http://mysite.com/callback?this=one')

        expect(::Oauth2Token).to receive(:create!).with(client_application: @app,
                                                        user: @user,
                                                        callback_url: 'http://mysite.com/callback?this=one',
                                                        scope: 'a b').and_return(@token)

        @authorizer = described_class.new @user, true, response_type: 'token',
                                                       scope: 'a b',
                                                       client_id: 'client id',
                                                       redirect_uri: 'http://mysite.com/callback?this=one'
        expect(@authorizer).to be_authorized
        expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?this=one#access_token=secret%20auth%20code')
      end
    end
  end

  describe 'user does not authorize' do
    it 'sends error' do
      @authorizer = described_class.new @user, false, response_type: 'token',
                                                      scope: 'a b',
                                                      client_id: 'client id',
                                                      redirect_uri: 'http://mysite.com/callback'

      expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback#error=access_denied')
      expect(@authorizer).not_to be_authorized
    end

    it 'sends error with state and query params in callback' do
      app = instance_double('ClientApplication')
      allow(::ClientApplication).to receive(:find_by!).and_return(app)
      allow(app).to receive(:callback_url).and_return('http://mysite.com/callback?this=one')

      @authorizer = described_class.new @user, false, response_type: 'token',
                                                      scope: 'a b',
                                                      client_id: 'client id',
                                                      redirect_uri: 'http://mysite.com/callback?this=one',
                                                      state: 'my customer'

      expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback?this=one#error=access_denied&state=my%20customer')
      expect(@authorizer).not_to be_authorized
    end
  end

  it 'handles unsupported response type' do
    @user = double('user')

    @authorizer = described_class.new @user, false, response_type: 'my new',
                                                    scope: 'a b',
                                                    client_id: 'client id',
                                                    redirect_uri: 'http://mysite.com/callback'

    expect(@authorizer.redirect_uri).to eq('http://mysite.com/callback#error=unsupported_response_type')
    expect(@authorizer).not_to be_authorized
  end
end
