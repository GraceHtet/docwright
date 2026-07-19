# frozen_string_literal: true

module Docwright
  module Extractors
    class ServicesExtractor
      def generate
        Rails.application.eager_load!

        services = find_services
        if services.empty?
          puts "DocWright: no services found — skipping services.md"
          return
        end

        FileUtils.mkdir_p("docs")
        services.each do |service|
          lines = build_service_lines(service)
          notes = "#### Notes for #{service[:name]}\n<!-- Describe when to use this service and what it does -->"
          Docwright::Merger.write_named("docs/services.md", service[:name], lines.join("\n"), notes)
        end

        summary_lines = ["### Summary", "- Total services: #{services.size}"]
        Docwright::Merger.write_named("docs/services.md", "_summary", summary_lines.join("\n"), "")

        puts "DocWright: wrote docs/services.md"
      end

      private

      def find_services # rubocop:disable Metrics/MethodLength
        return [] unless Dir.exist?("app/services")

        Dir.glob("app/services/**/*.rb").filter_map do |path|
          class_name = path.gsub("app/services/", "")
                           .gsub(".rb", "")
                           .camelize

          klass = Object.const_get(class_name)
          methods = klass.public_instance_methods(false).map(&:to_s).sort

          { name: class_name, path: path, methods: methods }
        rescue NameError
          nil
        end
      end

      def build_service_lines(service)
        lines = []
        lines << "#### #{service[:name]}"
        lines << "- Location: #{service[:path]}"
        lines << if service[:methods].any?
                   "- Public methods: #{service[:methods].join(", ")}"
                 else
                   "- Public methods: none"
                 end
        lines
      end
    end
  end
end
