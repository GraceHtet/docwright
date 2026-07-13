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

      private

      def template(name, description)
        <<~MD
          # #{name.gsub("_", " ").capitalize}

          #{description}

          ## Overview
          <!-- Describe this feature at a high level -->

          ## Flow
          <!-- Describe the step by step flow of this feature -->

          ## Models involved
          <!-- List the models this feature touches -->

          ## Edge cases
          <!-- Document important edge cases for this feature -->
        MD
      end
    end
  end
end
