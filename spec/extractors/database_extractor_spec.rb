# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::DatabaseExtractor do
  let(:tmp_dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmp_dir) }

  describe "#generate" do
    it "generate docs/database.md file" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      expect(File.exist?(File.join(tmp_dir, "docs", "database.md"))).to be true
    end

    it "includes table names in the output" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))
      expect(content).to include("## users")
      expect(content).to include("## posts")
    end

    it "includes column names in the output" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))
      expect(content).to include("name")
      expect(content).to include("email")
      expect(content).to include("title")
    end

    it "includes column types in the output" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))
      expect(content).to include("string")
      expect(content).to include("boolean")
    end

    it "exclude internal Rails tables" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))
      expect(content).not_to include("schema_migrations")
      expect(content).not_to include("ar_internal_metadata")
    end

    it "wraps content in auto marker" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))
      expect(content).to include("<!-- DOCWRIGHT:AUTO -->")
      expect(content).to include("<!-- DOCWRIGHT:END -->")
    end

    it "places columns under correct table heading" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::DatabaseExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "database.md"))

      # posts comes first (alphabetical)
      posts_section = content[/## posts.*?(?=## users)/m]
      expect(posts_section).to include("**title** (string)")
      expect(posts_section).not_to include("**email**")

      # users comes second
      users_section = content[/## users.*/m]
      expect(users_section).to include("**email** (string)")
      expect(users_section).not_to include("**title**")
    end
  end
end
