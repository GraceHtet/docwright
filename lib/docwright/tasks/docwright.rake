# frozen_string_literal: true

namespace :docwright do
  desc "Generate documentation for this Rails application"
  task generate: :environment do
    Docwright::Extractors::DatabaseExtractor.new.generate
    Docwright::Extractors::ApiExtractor.new.generate
    Docwright::Extractors::ModelExtractor.new.generate
    Docwright::Generators::ManualGenerator.new.generate
    Docwright::Generators::FeatureGenerator.new.generate
  end
end
