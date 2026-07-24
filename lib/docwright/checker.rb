# frozen_string_literal: true

module Docwright
  class Checker
    REQUIRED_FILES = %w[
      docs/database.md
      docs/api.md
      docs/models.md
      docs/overview.md
      docs/business_rules.md
      docs/setup.md
      docs/architecture.md
      docs/deployment.md
      docs/security.md
      docs/troubleshooting.md
      docs/changelog.md
      docs/readme.md
    ].freeze

    def run
      puts "\nDocWright Check"
      puts "===============\n\n"

      missing = check_required_files
      missing += check_optional_files
      placeholders = check_placeholder_content
      empty_notes = check_note_slots

      print_report(missing, placeholders, empty_notes)

      exit(1) if missing.any? || placeholders.any? || empty_notes.any?
    end

    private

    def check_required_files
      missing = []
      REQUIRED_FILES.each do |file|
        if File.exist?(file)
          puts "✅ #{file}"
        else
          puts "❌ #{file} — missing"
          missing << file
        end
      end

      missing
    end

    def check_optional_files
      missing = []
      optional = load_optional_config
      return missing if optional.empty?

      optional_file_map = {
        "auth_and_permissions" => "docs/auth_and_permissions.md",
        "background_jobs" => "docs/background_jobs.md",
        "services" => "docs/services.md",
        "concerns" => "docs/concerns.md"
      }

      optional_file_map.each do |key, file|
        next unless optional[key]

        if File.exist?(file)
          puts "✅ #{file}"
        else
          puts "❌ #{file} — missing (enabled in .docwright.yml)"
          missing << file
        end
      end

      missing
    end

    def load_optional_config
      return {} unless File.exist?(".docwright.yml")

      require "yaml"
      config = YAML.load_file(".docwright.yml")
      return {} unless config.is_a?(Hash)

      config["optional_docs"] || {}
    end

    def check_placeholder_content
      placeholders = []
      all_files = REQUIRED_FILES.select { |f| File.exist?(f) }

      all_files.each do |file|
        content = File.read(file)
        lines = content.lines.map(&:strip).reject(&:empty?)
        real_lines = lines.reject { |l| l.start_with?("#", "<!--", "-->") }

        if real_lines.empty?
          puts "⚠  #{file} — placeholder content only"
          placeholders << file
        end
      end

      placeholders
    end

    def check_note_slots
      empty_notes = []
      md_files = Dir.glob("docs/**/*.md")

      md_files.each do |file|
        content = File.read(file)
        lines = content.lines.map(&:chomp)

        lines.each_with_index do |line, i|
          next unless line.match?(/^#+\s+Notes for/)
          next if line.match?(/Notes for _summary/)

          following_lines = []
          j = i + 1
          while j < lines.size && !lines[j].match?(/^#+\s+Notes for/) && !lines[j].include?("DOCWRIGHT")
            following_lines << lines[j]
            j += 1
          end

          real_content = following_lines.map(&:strip).reject(&:empty?).reject { |l| l.start_with?("<!--", "-->") }

          if real_content.empty?
            puts "⚠  #{file} — empty notes slot: #{line.strip}"
            empty_notes << "#{file}: #{line.strip}"
          end
        end
      end

      empty_notes
    end

    def print_report(missing, placeholders, empty_notes)
      puts "\n==============="
      puts "DocWright Check Summary"
      puts "===============\n\n"

      total_size = missing.size + placeholders.size + empty_notes.size

      if total_size.zero?
        puts "✅ All checks passed! Documentation looks complete."
      else
        puts "❌ Missing files: #{missing.size}"
        puts "⚠  Placeholder content: #{placeholders.size}"
        puts "⚠  Empty notes slots: #{empty_notes.size}"
        puts "\nRun 'rake docwright:generate' to generate missing files."
        puts "Placeholder content: open the files and add your documentation."
      end
    end
  end
end
