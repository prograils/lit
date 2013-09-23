require 'rails/generators'
module Lit
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      class_option "key-value-engine", :type => :string
      class_option "authentication-function", :type => :string
      class_option "no-migrate", :type => :boolean

      source_root File.expand_path("../install/templates", __FILE__)

      desc "Automates Lit installation"

      def copy_migrations
        puts "Copying Lit migrations..."
        Dir.chdir(::Rails.root) do
          `rake lit:install:migrations`
        end
      end

      def set_authentication_function
        @authentication_function = options["authentication-function"].presence ||
              ask("What's the authentication function, ie. :authenticate_user! :").presence ||
              nil
      end

      def set_key_value_engine
        @key_value_engine = options["key-value-engine"].presence ||
              ask("What's the key value engine? ([hash] OR redis):").presence ||
              :hash
      end

      def add_redis_dependency
        if @key_value_engine == 'redis'
          puts "Adding redis dependency"
          gem 'redis'
          Bundler.with_clean_env do
            run "bundle install"
          end
        end
      end

      def generate_api_key
        @api_key = SecureRandom.base64 32
      end

      def add_lit_initializer
        path = "#{::Rails.root}/config/initializers/lit.rb"
        if File.exists?(path)
          puts "Skipping config/initializers/lit.rb creation, file already exists!"
        else
          puts "Adding lit initializer (config/initializers/lit.rb)..."
          template "initializer.rb", path
        end
      end

      def run_migrations
        unless options["no-migrate"]
          puts "Running rake db:migrate"
          `rake db:migrate`
        end
      end

      def clear_cache
        Lit.init.cache.reset
      end

      def mount_engine
        puts "Mounting Lit::Engine at \"/lit\" in config/routes.rb..."
        route "mount Lit::Engine => '/lit'"
      end
    end
  end
end
