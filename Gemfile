# frozen_string_literal: true

source 'http://rubygems.org'

# Specify your gem's dependencies in oauth-plugin.gemspec
gemspec

require 'rbconfig'

platforms :ruby do
  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'growl'
    gem 'rb-fsevent'
  end
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'libnotify',  '~> 0.1.3'
    gem 'rb-inotify', '>= 0.5.1'
  end
end

platforms :jruby do
  gem 'growl' if RbConfig::CONFIG['target_os'] =~ /darwin/i
  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'libnotify',  '~> 0.1.3'
    gem 'rb-inotify', '>= 0.5.1'
  end
end
