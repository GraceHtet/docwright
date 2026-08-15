# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::ApiExtractor do
  let(:tmp_dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmp_dir) }

  describe "#generate" do
    it "generates docs/api.md file" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      expect(File.exist?(File.join(tmp_dir, "docs", "api.md"))).to be true
    end

    it "contains HTTP verbs" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).to include("GET")
      expect(content).to include("POST")
      expect(content).to include("DELETE")
    end

    it "contains route paths" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).to include("/users")
      expect(content).to include("/posts")
    end

    it "contains controller#action format" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).to include("users#index")
      expect(content).to include("users#create")
      expect(content).to include("posts#show")
    end

    it "excludes Rails internal routes" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).not_to include("rails/")
      expect(content).not_to include("rails_")
    end

    it "wraps content in AUTO markers" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).to include("<!-- DOCWRIGHT:AUTO -->")
      expect(content).to include("<!-- DOCWRIGHT:END -->")
    end

    it "contains correct verb and action combination per route" do
      Dir.chdir(tmp_dir) do
        Docwright::Extractors::ApiExtractor.new.generate
      end

      content = File.read(File.join(tmp_dir, "docs", "api.md"))
      expect(content).to include("**GET** /users(.:format) -> users#index")
      expect(content).to include("**POST** /users(.:format) -> users#create")
      expect(content).to include("**DELETE** /users/:id(.:format) -> users#destroy")
    end
  end
end
