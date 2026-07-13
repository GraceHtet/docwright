# frozen_string_literal: true

module Docwright
  module Extractors
    class ModelExtractor
      def generate
        models = find_models
        FileUtils.mkdir_p("docs")

        models.each do |model|
          lines = []
          lines << "## #{model.name}"
          lines << "**Table:** #{model.table_name}\n"

          lines << "### Associations"
          associations = model.reflect_on_all_associations
          if associations.empty?
            lines << "- None"
          else
            associations.each do |a|
              lines << "- #{a.macro} :#{a.name}"
            end
          end

          lines << "\n### Validations"
          validations = model.validators
          if validations.empty?
            lines << "- None"
          else
            validations.each do |v|
              lines << "- #{v.class.name} on : #{v.attributes.join(", ")}"
            end
          end

          notes = "### Notes for #{model.name}\n<!-- Add your notes about #{model.name} here -->"
          Docwright::Merger.write_named("docs/models.md", model.name, lines.join("\n"), notes)
        end

        puts "DocWright: wrote docs/models.md"
      end

      private

      def find_models
        Rails.application.eager_load!
        ActiveRecord::Base.descendants.reject { |m| m.abstract_class? }.sort_by(&:name)
      end
    end
  end
end
