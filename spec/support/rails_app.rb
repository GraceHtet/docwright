# frozen_string_literal: true

require "rails"
require "active_record"
require "action_controller"
require "action_dispatch"

module TestApp
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
    config.logger = Logger.new(nil) # silence Rails logs during tests
  end
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.text :body
    t.boolean :published, default: false
    t.references :user, foreign_key: true
    t.timestamps
  end
end

class User < ActiveRecord::Base
  has_many :posts
  validates :name, presence: true
end

class Post < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
end

TestApp::Application.routes.draw do
  resources :users do
    resources :posts
  end
end

class UsersController < ActionController::Base
  before_action :authenticate_user!

  private

  def authenticate_user!
    # test auth filter
  end
end

class PostsController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_post, only: %i[show edit update destroy]

  private

  def authenticate_user!
    # test auth filter
  end

  def set_post
    # test filter with only condition
  end
end

require "active_job"

class ApplicationJob < ActiveJob::Base; end

class TestJob < ApplicationJob
  queue_as :default
end

class AnotherJob < ApplicationJob
  queue_as :mailers
end

class ArticleService
  def call
    # main entry point
  end

  def publish(article)
    # publish logic
  end

  private

  def validate
    # private — should NOT appear in output
  end
end
