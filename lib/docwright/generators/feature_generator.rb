# frozen_string_literal: true

require "yaml"

module Docwright
  module Generators
    class FeatureGenerator
      CONFIG_FILE = ".docwright.yml"

      def generate
        return unless File.exist?(CONFIG_FILE)

        config = YAML.load_file(CONFIG_FILE)
        features = config["features"] || []
        return if features.empty?

        FileUtils.mkdir_p("docs/features")

        features.each do |feature|
          name = feature["name"]
          description = feature["description"]
          path = "docs/features/#{name}.md"

          if File.exist?(path)
            puts "DocWright: skipped #{path} (already exists)"
          else
            File.write(path, template(name, description))
            puts "DocWright: wrote #{path}"
          end
        end
      end

      def generate_single(path, filename)
        return if File.exist?(path)

        name = filename.gsub(".md", "")

        description = "<!-- Describe the feature -->"
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, template(name, description))
      end

      private

      def template(name, description)
        <<~MD
          # #{name.gsub("_", " ").capitalize}

          #{description}

          ## Overview
          <!-- Describe this feature at a high level -->

          ## Models involved
          <!-- Auto-detection coming in a future phase -->

          ## Controllers and actions
          <!-- Auto-detection coming in a future phase -->

          ## Services
          <!-- Auto-detection coming in a future phase -->

          ## Background jobs
          <!-- Auto-detection coming in a future phase -->

          ## Views
          <!-- Auto-detection coming in a future phase -->

          ## User flows

          ### Happy path
          <!-- Describe the main successful flow step by step -->
          <!-- Example: User > sidebar > article list > click create > fill form > submit -->

          ### Alternative paths
          <!-- Describe edge cases, error states, or alternative routes -->

          ## Edge cases
          <!-- Document important edge cases for this feature -->
        MD
      end
    end
  end
end
