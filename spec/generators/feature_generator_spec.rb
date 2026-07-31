# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Generators::FeatureGenerator do
  let(:tmp_dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmp_dir) }

  describe "#generate" do
    it "does nothing when .docwright.yml does not exist" do
      Dir.chdir(tmp_dir) do
        Docwright::Generators::FeatureGenerator.new.generate
      end

      expect(File.exist?(File.join(tmp_dir, "docs", "features"))).to be false
    end

    it "does nothing when features list is empty" do
      File.write(File.join(tmp_dir, ".docwright.yml"), "features: []")

      Dir.chdir(tmp_dir) do
        Docwright::Generators::FeatureGenerator.new.generate
      end

      expect(File.exist?(File.join(tmp_dir, "docs", "features"))).to be false
    end

    it "creates feature file for each declared feature" do
      config = "features:\n  - name: qr_flow\n    description: QR code flow\n  - name: subscriptions\n    description: Billing"
      File.write(File.join(tmp_dir, ".docwright.yml"), config)

      Dir.chdir(tmp_dir) do
        Docwright::Generators::FeatureGenerator.new.generate
      end

      expect(File.exist?(File.join(tmp_dir, "docs", "features", "qr_flow.md"))).to be
      expect(File.exist?(File.join(tmp_dir, "docs", "features", "subscriptions.md"))).to be true
    end

    it "created file contains correct template content" do
      config = "features:\n  - name: qr_flow\n    description: QR code generation"
      File.write(File.join(tmp_dir, ".docwright.yml"), config)

      Dir.chdir(tmp_dir) do
        Docwright::Generators::FeatureGenerator.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "features", "qr_flow.md"))
      expect(content).to include("# Qr flow")
      expect(content).to include("QR code generation")
      expect(content).to include("## Overview")
      expect(content).to include("## User flows")
    end

    it "skips feature files that already exist" do
      config = "features:\n  - name: qr_flow\n    description: QR code flow"
      File.write(File.join(tmp_dir, ".docwright.yml"), config)

      features_dir = File.join(tmp_dir, "docs", "features")
      FileUtils.mkdir_p(features_dir)
      existing_path = File.join(features_dir, "qr_flow.md")
      File.write(existing_path, "my custom qr flow notes")

      Dir.chdir(tmp_dir) do
        Docwright::Generators::FeatureGenerator.new.generate
      end

      expect(File.read(existing_path)).to eq("my custom qr flow notes")
    end
  end

  describe "#generate_single" do
    it "creates file when it does not exist" do
      path = File.join(tmp_dir, "qr_flow.md")
      Docwright::Generators::FeatureGenerator.new.generate_single(path, "qr_flow.md")

      expect(File.exist?(path)).to be true
    end

    it "created file contains correct template content" do
      path = File.join(tmp_dir, "qr_flow.md")
      Docwright::Generators::FeatureGenerator.new.generate_single(path, "qr_flow.md")

      content = File.read(path)
      expect(content).to include("# Qr flow")
      expect(content).to include("## Overview")
      expect(content).to include("## User flows")
    end

    it "skips file when it already exists" do
      path = File.join(tmp_dir, "qr_flow.md")
      File.write(path, "my original content")

      Docwright::Generators::FeatureGenerator.new.generate_single(path, "qr_flow.md")

      expect(File.read(path)).to eq("my original content")
    end
  end
end
