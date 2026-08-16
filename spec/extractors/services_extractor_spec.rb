# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::ServicesExtractor do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe "#generate" do
    before do
      services_dir = File.join(tmpdir, "app", "services")
      FileUtils.mkdir_p(services_dir)
      File.write(File.join(services_dir, "article_service.rb"), <<~RUBY)
        class ArticleService
          def call; end
          def publish(article); end
          private
          def validate; end
        end
      RUBY

      Dir.chdir(tmpdir) do
        Docwright::Extractors::ServicesExtractor.new.generate
      end
    end

    let(:content) { File.read(File.join(tmpdir, "docs", "services.md")) }

    it "generates docs/services.md file" do
      expect(File.exist?(File.join(tmpdir, "docs", "services.md"))).to be true
    end

    it "contains service class names" do
      expect(content).to include("ArticleService")
    end

    it "contains named AUTO markers per service" do
      expect(content).to include("<!-- DOCWRIGHT:AUTO:ArticleService -->")
      expect(content).to include("<!-- DOCWRIGHT:END:ArticleService -->")
    end

    it "has notes slot outside auto block per service" do
      expect(content).to include("#### Notes for ArticleService")
      service_end = content.index("<!-- DOCWRIGHT:END:ArticleService -->")
      service_notes = content.index("#### Notes for ArticleService")
      expect(service_notes).to be > service_end
    end

    it "contains service file location" do
      expect(content).to include("app/services/article_service.rb")
    end

    it "contains public method names" do
      expect(content).to include("call")
      expect(content).to include("publish")
    end

    it "does not contain private method names" do
      service_section = content[/<!-- DOCWRIGHT:AUTO:ArticleService -->.*?<!-- DOCWRIGHT:END:ArticleService -->/m]
      expect(service_section).not_to include("validate")
    end

    it "contains summary count" do
      expect(content).to include("Total services: 1")
    end

    it "does not have notes slot for _summary block" do
      expect(content).not_to include("### Notes for _summary")
    end
  end

  describe "#generate with eager_load_failed" do
    it "skips generation when eager_load_failed is true" do
      Dir.chdir(tmpdir) do
        expect do
          Docwright::Extractors::ServicesExtractor.new.generate(true)
        end.to output(a_string_including("skipped services")).to_stdout
      end

      expect(File.exist?(File.join(tmpdir, "docs", "services.md"))).to be false
    end
  end
end
