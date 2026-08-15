# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::ModelExtractor do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe "#generate" do
    before do
      Dir.chdir(tmpdir) do
        Docwright::Extractors::ModelExtractor.new.generate
      end
    end

    let(:content) { File.read(File.join(tmpdir, "docs", "models.md")) }

    it "generates docs/models.md file" do
      expect(File.exist?(File.join(tmpdir, "docs", "models.md"))).to be true
    end

    it "documents all models" do
      expect(content).to include("## User")
      expect(content).to include("## Post")
      expect(content.scan(/^## \w/).size).to eq(2)
    end

    it "contains model headings" do
      expect(content).to include("## User")
      expect(content).to include("## Post")
    end

    it "contains associations" do
      expect(content).to include("has_many :posts")
      expect(content).to include("belongs_to :user")
    end

    it "contains validations" do
      expect(content).to include("PresenceValidator")
      expect(content).to include(": name")
      expect(content).to include(": title")
    end

    it "contains named AUTO markers per model" do
      expect(content).to include("<!-- DOCWRIGHT:AUTO:User -->")
      expect(content).to include("<!-- DOCWRIGHT:END:User -->")
      expect(content).to include("<!-- DOCWRIGHT:AUTO:Post -->")
      expect(content).to include("<!-- DOCWRIGHT:END:Post -->")
    end

    it "excludes Rails internal models" do
      expect(content).not_to include("## ApplicationRecord")
    end

    it "has notes slot outside auto block per model" do
      expect(content).to include("### Notes for User")
      expect(content).to include("### Notes for Post")
      user_end = content.index("<!-- DOCWRIGHT:END:User -->")
      user_notes = content.index("### Notes for User")
      expect(user_notes).to be > user_end
    end
  end
end
