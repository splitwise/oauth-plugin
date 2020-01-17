# frozen_string_literal: true

module Mongoid
  module Generators
    class OauthConsumerGenerator < Rails::Generators::Base
      source_root File.expand_path('oauth_consumer_templates', __dir__)

      def check_class_collisions
        class_collisions '', %w[ConsumerToken]
      end

      def copy_models
        template 'consumer_token.rb', File.join('app/models', 'consumer_token.rb')
      end
    end
  end
end
