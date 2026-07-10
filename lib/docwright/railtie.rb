# frozen_string_literal: true

module Docwright
  # Railtie for integrating Docwright with Rails.
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks/docwright.rake", __dir__)
    end
  end
end
