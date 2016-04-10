begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'rails', git: 'https://github.com/rails/rails'
  #gem 'rails', path: '/home/tiki/rails'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  #gem 'ruby-prof'
  #gem 'memory_profiler'
end

require 'rack/test'
require 'action_controller/railtie'
require 'active_support/railtie'
require 'action_dispatch'
require 'action_dispatch/routing/inspector'


module TestEngine
  class Engine < ::Rails::Engine
    isolate_namespace TestEngine

    routes.draw do
      resources :non_api_routes
    end
  end

  class NonApiRoutesController < ActionController::Base
    def index
      render plain: ''
    end

    def show
      render plain: ''
    end

    def new
      render plain: ''
    end

    def create
      render plain: ''
    end

    def edit
      render plain: ''
    end

    def update
      render plain: ''
    end

    def destroy
      render plain: ''
    end
  end
end

class TestApp < Rails::Application
  config.api_only = true
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  ActiveSupport::Dependencies.autoload_paths << Rails.root
  config.cache_classes = false

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    root to: 'api_routes#index'
    resources :api_routes
    mount TestEngine::Engine, at: 'test_engine'
  end
end

class ApiRoutesController < ActionController::API
    def index
      render plain: ''
    end

    def show
      render plain: ''
    end

    def create
      render plain: ''
    end

    def update
      render plain: ''
    end

    def destroy
      render plain: ''
    end
end

require 'minitest/autorun'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class BugTest < Minitest::Test
  include Rack::Test::Methods

  def test_engine_routes
    # Print out routes
    # all_routes = Rails.application.routes.routes
    # inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
    # puts inspector.format(ActionDispatch::Routing::ConsoleFormatter.new)
    
    ## Test default API routes
    api_without_id = %w{index create}
    api_with_id = %w{show update destroy}
    api_invalid = %w{new edit}
    app_route_helper = Rails.application.routes

    # Index and Create should route without an ID
    api_without_id.each do |key|
      assert proc {
        get(app_route_helper.path_for(controller: 'api_routes', action: key))
        last_response.status == 200
      }
    end

    # Show, Update and Destroy should route with ID
    api_with_id.each do |key|
      assert proc {
        get(app_route_helper.path_for(controller: 'api_routes', action: key, id: 0))
        last_response.status == 200
      }
    end

    # New and Edit should not route in API mode
    assert_raises(ActionController::UrlGenerationError) do
      app_route_helper.path_for(controller: 'api_routes', action: 'new')
    end

    assert_raises(ActionController::UrlGenerationError) do
      app_route_helper.path_for(controller: 'api_routes', action: 'edit', id: 0)
    end

    ## Test for mounted Engine
    engine_without_id = %w{index create new}
    ending_with_id = %w{show update destroy edit}
    engine_route_helper = TestEngine::Engine.routes

    # Index, Create, and New should route without an ID
    engine_without_id.each do |key|
      assert proc {
        get(engine_route_helper.path_for(controller: 'test_engine/non_api_routes', action: key))
        last_response.status == 200
      }
    end

    # Show, Update, Destroy, and Edit should route with ID
    api_with_id.each do |key|
      assert proc {
        get(engine_route_helper.path_for(controller: 'test_engine/non_api_routes', action: key, id: 0))
        last_response.status == 200
      }
    end
  end

  private
    def app
      Rails.application
    end
end
