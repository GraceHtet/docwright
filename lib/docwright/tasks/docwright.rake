# frozen_string_literal: true

namespace :docwright do
  desc "Generate documentation for this Rails application"
  task generate: :environment do
    # Docwright::Extractors::DatabaseExtractor.new.generate
    # Docwright::Extractors::ApiExtractor.new.generate
    # Docwright::Extractors::ModelExtractor.new.generate
    # Docwright::Generators::ManualGenerator.new.generate
    # Docwright::Generators::FeatureGenerator.new.generate
    Docwright::Wizard.new.run
  end

  desc "Check Documentation completeness"
  task check: :environment do
    Docwright::Checker.new.run
  end

  desc "Search documentation"
  task :search, [:term] => :environment do |_, args|
    term = args[:term]
    if term.nil? || term.empty?
      puts "Usage: rake docwright:search[your_search_term]"
    else
      Docwright::Searcher.new(term).run
    end
  end
end
