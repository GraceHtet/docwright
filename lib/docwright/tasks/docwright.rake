# frozen_string_literal: true

namespace :docwright do
  desc "Generate documentation for this Rails application"
  task generate: :environment do
    puts "DocWright: generating documentation..."
  end
end
