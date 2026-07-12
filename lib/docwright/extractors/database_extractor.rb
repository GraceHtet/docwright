# frozen_string_literal: true

module Docwright
  module Extractors
    class DatabaseExtractor
      def generate
        skip = %w[schema_migrations ar_internal_metadata]
        tables = ActiveRecord::Base.connection.tables.reject { |t| skip.include?(t) }.sort
        lines = ["# Database Documentation\n"]

        tables.each do |table|
          lines << "## #{table}\n"
          columns = ActiveRecord::Base.connection.columns(table)
          columns.each do |col|
            lines << "- **#{col.name}** (#{col.type})"
          end

          lines << ""
        end

        FileUtils.mkdir_p("docs")
        Docwright::Merger.write("docs/database.md", lines.join("\n"))
        puts "DocWright: Wrote docs/database.md"
      end
    end
  end
end
