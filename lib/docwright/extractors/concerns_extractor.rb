# frozen_string_literal: true

module Docwright
  module Extractors
    class ConcernsExtractor
      def generate(eager_load_failed = false)
        unless defined?(ActiveRecord) && defined?(ActionController)
          puts "DocWright: skipped concerns.md — ActiveRecord or ActionController is not loaded."
          return
        end

        if eager_load_failed
          puts "DocWright: skipped concerns.md — eager_load failed"
          return
        end

        concerns = find_model_concerns + find_controller_concerns

        if concerns.empty?
          puts "DocWright: no concerns found — skipping concerns.md"
          return
        end

        FileUtils.mkdir_p("docs")

        concerns.each do |concern|
          lines = build_concern_lines(concern)
          notes = "#### Notes for #{concern[:name]}\n<!-- Describe what this concern adds and why it was extracted -->"
          Docwright::Merger.write_named("docs/concerns.md", concern[:name], lines.join("\n"), notes)
        end

        model_concerns = concerns.count { |c| c[:type] == "Model Concern" }
        controller_concerns = concerns.count { |c| c[:type] == "Controller Concern" }

        summary_lines = [
          "### Summary",
          "- Total concerns: #{concerns.size}",
          "- Model concerns: #{model_concerns}",
          "- Controller concerns: #{controller_concerns}"
        ]
        Docwright::Merger.write_named("docs/concerns.md", "_summary", summary_lines.join("\n"), "")

        puts "DocWright: wrote docs/concerns.md"
      end

      private

      def find_model_concerns
        find_concerns("app/models/concerns", "Model Concern", ActiveRecord::Base)
      end

      def find_controller_concerns
        find_concerns("app/controllers/concerns", "Controller Concern", ActionController::Base)
      end

      def find_concerns(path, type, base_class)
        return [] unless Dir.exist?(path)

        Dir.glob("#{path}/**/*.rb").filter_map do |file|
          class_name = file.gsub("#{path}/", "")
                           .gsub(".rb", "")
                           .camelize

          concern = Object.const_get(class_name)
          methods = concern.public_instance_methods(false).map(&:to_s).sort
          included_in = find_included_in(concern, base_class)

          { name: class_name, type: type, path: file, methods: methods, included_in: included_in }
        rescue NameError
          nil
        end
      end

      def find_included_in(concern, base_class)
        base_class.descendants
                  .select { |klass| klass.ancestors.include?(concern) }
                  .map(&:name)
                  .compact
                  .sort
      end

      def build_concern_lines(concern)
        lines = []
        lines << "#### #{concern[:name]}"
        lines << "- Type: #{concern[:type]}"
        lines << "- Location: #{concern[:path]}"
        lines << if concern[:methods].any?
                   "- Methods: #{concern[:methods].join(", ")}"
                 else
                   "- Methods: none"
                 end
        lines << if concern[:included_in].any?
                   "- Included in: #{concern[:included_in].join(", ")}"
                 else
                   "- Included in: none detected"
                 end
        lines
      end
    end
  end
end
