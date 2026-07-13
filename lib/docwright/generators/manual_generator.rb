# frozen_string_literal: true

module Docwright
  module Generators
    class ManualGenerator
      TEMPLATES = {
        "overview.md" => <<~MD,
          # Overview

          ## What is this app?
          <!-- Describe what this application does and why it exists -->

          ## Who is it for?
          <!-- Describe the target users or customers -->

          ## Key features
          <!-- List the main features of the application -->
        MD
        "business_rules.md" => <<~MD,
          # Business Rules

          ## Core rules
          <!-- Describe the fundamental business rules that drive this application -->

          ## Edge cases
          <!-- Document important edge cases and how they are handled -->
        MD
        "setup.md" => <<~MD,
          # Setup

          ## Requirements
          <!-- List required tools, languages, and versions -->

          ## Installation
          <!-- Step by step setup instructions -->

          ## Environment variables
          <!-- List all required environment variables and what they do -->

          ## Seed data
          <!-- Describe seed data and how to run it -->
        MD
        "architecture.md" => <<~MD,
          # Architecture

          ## High-level structure
          <!-- Describe the overall structure of the application -->

          ## Key design decisions
          <!-- Document important architectural decisions and the reasoning behind them -->

          ## External dependencies
          <!-- List external services, APIs, or libraries this app depends on -->
        MD
        "deployment.md" => <<~MD,
          # Deployment

          ## Environments
          <!-- List all environments and their purposes -->

          ## Deploy process
          <!-- Step by step deployment instructions -->

          ## Infrastructure
          <!-- Describe the infrastructure this app runs on -->
        MD
        "security.md" => <<~MD,
          # Security

          ## Authentication
          <!-- Describe how authentication works -->

          ## Authorization
          <!-- Describe how authorization and permissions work -->

          ## Sensitive data
          <!-- List sensitive data this app handles and how it is protected -->
        MD
        "troubleshooting.md" => <<~MD,
          # Troubleshooting

          ## Common problems
          <!-- List common issues and their solutions -->

          ## Debugging tips
          <!-- Useful tips for debugging this application -->
        MD
        "changelog.md" => <<~MD,
          # Changelog

          ## Unreleased
          <!-- Changes not yet in production -->

          ## [Version] - YYYY-MM-DD
          <!-- Document significant changes per release -->
        MD
        "readme.md" => <<~MD
          # [App Name]

          ## Overview
          <!-- Brief description of the application -->

          ## Quick start
          <!-- Fastest way to get the app running locally -->

          ## Documentation
          <!-- Link to or summarize key documentation -->
        MD
      }.freeze

      def generate
        FileUtils.mkdir_p("docs")
        TEMPLATES.each do |filename, content|
          path = "docs/#{filename}"
          if File.exist?(path)
            puts "DocWright: skipped #{path} (already exists)"
          else
            File.write(path, content)
            puts "DocWright: wrote #{path}"
          end
        end
      end
    end
  end
end
