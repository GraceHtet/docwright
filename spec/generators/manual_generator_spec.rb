# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Generators::ManualGenerator do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:docs_dir) { File.join(tmp_dir, "docs") }

  after { FileUtils.rm_rf(tmp_dir) }

  describe "#generate" do
    before { FileUtils.mkdir_p(docs_dir) }

    it "creates all 9 template files" do
      Dir.chdir(tmp_dir) do
        Docwright::Generators::ManualGenerator.new.generate
      end

      expected_files = %w[
        overview.md business_rules.md setup.md architecture.md
        deployment.md security.md troubleshooting.md changelog.md readme.md
      ]

      expected_files.each do |filename|
        expect(File.exist?(File.join(docs_dir, filename))).to be true
      end
    end

    it "writes correct heading in each file" do
      Dir.chdir(tmp_dir) do
        Docwright::Generators::ManualGenerator.new.generate
      end

      expect(File.read(File.join(docs_dir, "overview.md"))).to include("# Overview")
      expect(File.read(File.join(docs_dir, "setup.md"))).to include("# Setup")
      expect(File.read(File.join(docs_dir, "architecture.md"))).to include("# Architecture")
    end

    it "skips files that already exist" do
      existing_path = File.join(docs_dir, "overview.md")
      File.write(existing_path, "my custom content")

      Dir.chdir(tmp_dir) do
        Docwright::Generators::ManualGenerator.new.generate
      end

      expect(File.read(existing_path)).to eq("my custom content")
    end

    it "preserves original content in skipped files" do
      existing_path = File.join(docs_dir, "setup.md")
      File.write(existing_path, "custom setup notes")

      Dir.chdir(tmp_dir) do
        Docwright::Generators::ManualGenerator.new.generate
      end

      expect(File.read(existing_path)).to eq("custom setup notes")
      expect(File.read(existing_path)).not_to include("# Setup")
    end
  end

  describe "#generate_single" do
    it "creates file when it does not exist" do
      path = File.join(tmp_dir, "overview.md")
      Docwright::Generators::ManualGenerator.new.generate_single(path, "overview.md")

      expect(File.exist?(path)).to be true
    end

    it "created file contains correct content" do
      path = File.join(tmp_dir, "overview.md")
      Docwright::Generators::ManualGenerator.new.generate_single(path, "overview.md")

      expect(File.read(path)).to include("# Overview")
      expect(File.read(path)).to include("## What is this app?")
    end

    it "skips file and preserves original content when file already exists" do
      path = File.join(tmp_dir, "overview.md")
      File.write(path, "my original content")

      Docwright::Generators::ManualGenerator.new.generate_single(path, "overview.md")

      expect(File.read(path)).to eq("my original content")
    end

    it "does nothing for unknown filename" do
      path = File.join(tmp_dir, "unknown.md")
      Docwright::Generators::ManualGenerator.new.generate_single(path, "unknown.md")

      expect(File.exist?(path)).to be false
    end
  end
end
