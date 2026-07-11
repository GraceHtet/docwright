# frozen_string_literal: true

module Docwright
  module Extractors
    class ApiExtractor
      def generate
        lines = ["# Api Documentation\n"]

        routes = Rails.application.routes.routes
        routes.each do |route|
          next if route.name.to_s.start_with?("rails_")
          next if route.verb.empty?
          next if route.defaults[:controller].to_s.start_with?("rails/")

          lines << "- **#{route.verb}** #{route.path.spec} -> #{route.defaults[:controller]}##{route.defaults[:action]}"
        end

        FileUtils.mkdir_p("docs")
        File.write("docs/api.md", lines.join("\n"))
        puts "DocWright: wrote docs/api.md"
      end
    end
  end
end
