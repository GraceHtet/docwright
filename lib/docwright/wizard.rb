# frozen_string_literal: true

module Docwright
  class Wizard # rubocop:disable Metrics/ClassLength
    FIRST_RUN_MESSAGE = <<~MSG
      ============================================
      DocWright — Rails Documentation Generator
      ============================================

      This tool will generate a docs/ folder with:

        Auto-generated (safe to regenerate anytime):
          - database.md   — tables, columns, types
          - api.md        — routes and endpoints
          - models.md     — model associations and validations

        Manual templates (written once, never overwritten):
          - overview.md, setup.md, architecture.md,
            deployment.md, security.md, troubleshooting.md,
            business_rules.md, changelog.md, readme.md
          - docs/features/ — feature-specific docs

        Important:
          Never manually edit content inside
          <!-- DOCWRIGHT:AUTO --> blocks — it will be overwritten.
          Write your notes outside those markers.

      ============================================
    MSG

    DOCWRIGHT_YML_TEMPLATE = <<~YAML
      # DocWright feature configuration
      # Declare your app's features here and DocWright will generate a doc template for each one.
      ##{" "}
      # Optional narrative docs - set to true to generate
      # DocWright will only generate these if the relevant folders exist in your app
      ##{" "}
      # optional_docs:
      #   controllers: true
      #   background_jobs: true
      #   services: true
      #   auth_and_permissions: true
      #
      # Feature-specific docs
      # Uncomment and edit the example below to add your features:
      #
      # features:
      #   - name: qr_flow
      #     description: QR code generation and scanning flow
      #   - name: subscriptions
      #     description: Billing, plan management, and renewals
    YAML

    def run # rubocop:disable Metrics/MethodLength
      ## File.exist? also works for both files and directories but Dir.exist? is specific for folder and return nil if that is named as file name
      first_run = !Dir.exist?("docs")
      puts FIRST_RUN_MESSAGE if first_run

      create_config_if_missing

      puts "\nDocWright: scanning your app...\n\n"

      report = detection_pass
      display_report(report)

      return unless confirm

      generate_auto_files
      process_manual_files(report[:new_manual])
      process_manual_files(report[:new_features])

      puts "\nDocWright: done!\n"
    rescue Interrupt
      puts "\n\nDocWright: wizard cancelled."
    end

    private

    def create_config_if_missing
      return if File.exist?(".docwright.yml")

      File.write(".docwright.yml", DOCWRIGHT_YML_TEMPLATE)
      puts "DocWright: created .docwright.yml — add your features there.\n"
    end

    def detection_pass # rubocop:disable Metrics/MethodLength
      auto_files = %w[database.md api.md models.md]
      manual_files = %w[overview.md business_rules.md setup.md
                        architecture.md deployment.md security.md
                        troubleshooting.md changelog.md readme.md]

      feature_files = load_feature_files
      {
        auto: auto_files,
        new_manual: manual_files.reject { |f| File.exist?("docs/#{f}") },
        existing_manual: manual_files.select { |f| File.exist?("docs/#{f}") },
        new_features: feature_files.reject { |f| File.exist?("docs/features/#{f}") },
        existing_features: feature_files.select { |f| File.exist?("docs/features/#{f}") }
      }
    end

    def load_feature_files
      return [] unless File.exist?(".docwright.yml")

      require "yaml"
      config = YAML.load_file(".docwright.yml")
      return [] unless config.is_a?(Hash)

      (config["features"] || []).map { |f| "#{f["name"]}.md" }
    end

    def display_report(report) # rubocop:disable Metrics/CyclomaticComplexity
      puts "  Will regenerate (auto):"
      report[:auto].each { |f| puts "    - #{f}" }

      unless report[:new_manual].empty?
        puts "\n  Will generate (new manual templates):"
        report[:new_manual].each { |f| puts "    - #{f}" }
      end

      unless report[:new_features].empty?
        puts "\n  Will generate (new feature docs):"
        report[:new_features].each { |f| puts "    - #{f}" }
      end

      unless report[:existing_manual].empty?
        puts "\n  Will skip (already exist):"
        report[:existing_manual].each { |f| puts "    - #{f}" }
      end

      return if report[:existing_features].empty?

      puts "\n  Will skip (already exist):"
      report[:existing_features].each { |f| puts "    - #{f}" }
    end

    def confirm
      print "\nContinue? (y/n): "
      $stdin.gets.chomp.downcase == "y"
    end

    def generate_auto_files
      puts "\nDocWright: generating auto files..."
      Docwright::Extractors::DatabaseExtractor.new.generate
      Docwright::Extractors::ApiExtractor.new.generate
      Docwright::Extractors::ModelExtractor.new.generate
      generate_optional_docs
    end

    def generate_optional_docs
      return unless File.exist?(".docwright.yml")

      require "yaml"
      config = YAML.load_file(".docwright.yml")
      return unless config.is_a?(Hash)

      optional = config["optional_docs"] || {}
      Docwright::Extractors::AuthExtractor.new.generate if optional["auth_and_permissions"]
      Docwright::Extractors::BackgroundJobsExtractor.new.generate if optional["background_jobs"]
      Docwright::Extractors::ServicesExtractor.new.generate if optional["services"]
    end

    def process_manual_files(files)
      return if files.empty?

      files.each do |filename|
        feature = !%w[overview.md business_rules.md setup.md
                      architecture.md deployment.md security.md
                      troubleshooting.md changelog.md readme.md].include?(filename)

        path = feature ? "docs/features/#{filename}" : "docs/#{filename}"

        loop do
          puts "\nGenerate #{filename}?"
          puts "  [w] write in terminal"
          puts "  [e] open in $EDITOR"
          puts "  [s] skip for now"
          puts "  [q] quit wizard"
          print "Choice: "

          case $stdin.gets.chomp.downcase
          when "w"
            write_in_terminal(path)
            break
          when "e"
            open_in_editor(path)
            break
          when "s"
            write_template(path, filename)
            puts "DocWright: skipped #{filename} — template saved, fill it in later"
            break
          when "q"
            puts "DocWright: wizard exited."
            return
          else
            puts "Invalid choice. Please enter w, e, s, or q."
          end
        end
      end
    end

    def write_in_terminal(path)
      puts "Type your content. Type 'END' on a new line when done (or Ctrl+C to cancel):"

      lines = []
      begin
        loop do
          line = $stdin.gets.chomp
          break if line == "END"
          break if %w[exit q].include?(line.downcase)

          lines << line
        end
      rescue Interrupt
        puts "\nCancelled."
        return
      end

      if lines.empty?
        puts "DocWright: nothing written, skipping #{path}"
        return
      end

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, lines.join("\n"))
      puts "DocWright: wrote #{path}"
    end

    def open_in_editor(path)
      FileUtils.mkdir_p(File.dirname(path))
      write_template(path, File.basename(path))
      editor = ENV["EDITOR"] || "nano"
      system("#{editor} #{path}")
      puts "DocWright: wrote #{path}"
    end

    def write_template(path, filename)
      FileUtils.mkdir_p(File.dirname(path))
      Docwright::Generators::ManualGenerator.new.generate_single(path, filename)
    end
  end
end
