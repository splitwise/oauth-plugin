# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe RequestToken do
  fixtures :client_applications, :users, :oauth_tokens
  before(:each) do
    @token = described_class.create client_application: client_applications(:one)
  end

  it 'is valid' do
    expect(@token).to be_valid
  end

  it 'does not have errors' do
    @token.errors.should_not == []
  end

  it 'has a token' do
    @token.token.should_not be_nil
  end

  it 'has a secret' do
    @token.secret.should_not be_nil
  end

  it 'is not authorized' do
    @token.should_not be_authorized
  end

  it 'is not invalidated' do
    @token.should_not be_invalidated
  end

  it 'does not have a verifier' do
    expect(@token.verifier).to be_nil
  end

  it 'is not oob' do
    @token.should_not be_oob
  end

  describe 'OAuth 1.0a' do
    describe 'with provided callback' do
      before(:each) do
        @token.callback_url = 'http://test.com/callback'
      end

      it 'is not oauth10' do
        @token.should_not be_oauth10
      end

      it 'is not oob' do
        @token.should_not be_oob
      end

      describe 'authorize request' do
        before(:each) do
          @token.authorize!(users(:quentin))
        end

        it 'is authorized' do
          expect(@token).to be_authorized
        end

        it 'has authorized at' do
          @token.authorized_at.should_not be_nil
        end

        it 'has user set' do
          expect(@token.user).to eq(users(:quentin))
        end

        it 'has verifier' do
          @token.verifier.should_not be_nil
        end

        describe 'exchange for access token' do
          before(:each) do
            @token.provided_oauth_verifier = @token.verifier
            @access = @token.exchange!
          end

          it 'is valid' do
            expect(@access).to be_valid
          end

          it 'has no error messages' do
            @access.errors.full_messages.should == []
          end

          it 'invalidates request token' do
            expect(@token).to be_invalidated
          end

          it 'sets user on access token' do
            expect(@access.user).to eq(users(:quentin))
          end

          it 'authorizes accesstoken' do
            expect(@access).to be_authorized
          end
        end

        describe 'attempt exchange with invalid verifier (OAuth 1.0a)' do
          before(:each) do
            @value = @token.exchange!
          end

          it 'returns false' do
            @value.should == false
          end

          it 'does not invalidate request token' do
            @token.should_not be_invalidated
          end
        end
      end

      describe 'attempt exchange with out authorization' do
        before(:each) do
          @value = @token.exchange!
        end

        it 'returns false' do
          @value.should == false
        end

        it 'does not invalidate request token' do
          @token.should_not be_invalidated
        end
      end

      it 'returns 1.0a style to_query' do
        @token.to_query.should == "oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
      end
    end

    describe 'with oob callback' do
      before(:each) do
        @token.callback_url = 'oob'
      end

      it 'is not oauth10' do
        @token.should_not be_oauth10
      end

      it 'is oob' do
        expect(@token).to be_oob
      end

      describe 'authorize request' do
        before(:each) do
          @token.authorize!(users(:quentin))
        end

        it 'is authorized' do
          expect(@token).to be_authorized
        end

        it 'has authorized at' do
          @token.authorized_at.should_not be_nil
        end

        it 'has user set' do
          expect(@token.user).to eq(users(:quentin))
        end

        it 'has verifier' do
          @token.verifier.should_not be_nil
        end

        describe 'exchange for access token' do
          before(:each) do
            @token.provided_oauth_verifier = @token.verifier
            @access = @token.exchange!
          end

          it 'invalidates request token' do
            expect(@token).to be_invalidated
          end

          it 'sets user on access token' do
            expect(@access.user).to eq(users(:quentin))
          end

          it 'authorizes accesstoken' do
            expect(@access).to be_authorized
          end
        end

        describe 'attempt exchange with invalid verifier (OAuth 1.0a)' do
          before(:each) do
            @value = @token.exchange!
          end

          it 'returns false' do
            @value.should == false
          end

          it 'does not invalidate request token' do
            @token.should_not be_invalidated
          end
        end
      end

      describe 'attempt exchange with out authorization invalid verifier' do
        before(:each) do
          @value = @token.exchange!
        end

        it 'returns false' do
          @value.should == false
        end

        it 'does not invalidate request token' do
          @token.should_not be_invalidated
        end
      end

      it 'returns 1.0 style to_query' do
        @token.to_query.should == "oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
      end
    end
  end

  if defined? OAUTH_10_SUPPORT && OAUTH_10_SUPPORT
    describe 'OAuth 1.0' do
      it 'is oauth10' do
        expect(@token).to be_oauth10
      end

      it 'is not oob' do
        @token.should_not be_oob
      end

      describe 'authorize request' do
        before(:each) do
          @token.authorize!(users(:quentin))
        end

        it 'is authorized' do
          expect(@token).to be_authorized
        end

        it 'has authorized at' do
          @token.authorized_at.should_not be_nil
        end

        it 'has user set' do
          expect(@token.user).to eq(users(:quentin))
        end

        it 'does not have verifier' do
          expect(@token.verifier).to be_nil
        end

        describe 'exchange for access token' do
          before(:each) do
            @access = @token.exchange!
          end

          it 'invalidates request token' do
            expect(@token).to be_invalidated
          end

          it 'sets user on access token' do
            expect(@access.user).to eq(users(:quentin))
          end

          it 'authorizes accesstoken' do
            expect(@access).to be_authorized
          end
        end
      end

      describe 'attempt exchange with out authorization' do
        before(:each) do
          @value = @token.exchange!
        end

        it 'returns false' do
          @value.should == false
        end

        it 'does not invalidate request token' do
          @token.should_not be_invalidated
        end
      end

      it 'returns 1.0 style to_query' do
        @token.to_query.should == "oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}"
      end
    end
  end
end
