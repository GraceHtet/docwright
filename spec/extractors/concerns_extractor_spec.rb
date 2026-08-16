# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::ConcernsExtractor do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe "#generate" do
    before do
      model_concerns_dir = File.join(tmpdir, "app", "models", "concerns")
      controller_concerns_dir = File.join(tmpdir, "app", "controllers", "concerns")
      FileUtils.mkdir_p(model_concerns_dir)
      FileUtils.mkdir_p(controller_concerns_dir)

      File.write(File.join(model_concerns_dir, "publishable.rb"), <<~RUBY)
        module Publishable
          extend ActiveSupport::Concern
          def publish; end
          def unpublish; end
        end
      RUBY

      File.write(File.join(controller_concerns_dir, "authenticatable.rb"), <<~RUBY)
        module Authenticatable
          extend ActiveSupport::Concern
          def authenticate!; end
        end
      RUBY

      Dir.chdir(tmpdir) do
        Docwright::Extractors::ConcernsExtractor.new.generate
      end
    end

    let(:content) { File.read(File.join(tmpdir, "docs", "concerns.md")) }

    it "generates docs/concerns.md file" do
      expect(File.exist?(File.join(tmpdir, "docs", "concerns.md"))).to be true
    end

    it "contains concern names" do
      expect(content).to include("Publishable")
      expect(content).to include("Authenticatable")
    end

    it "contains named AUTO markers per concern" do
      expect(content).to include("<!-- DOCWRIGHT:AUTO:Publishable -->")
      expect(content).to include("<!-- DOCWRIGHT:END:Publishable -->")
      expect(content).to include("<!-- DOCWRIGHT:AUTO:Authenticatable -->")
      expect(content).to include("<!-- DOCWRIGHT:END:Authenticatable -->")
    end

    it "has notes slot outside auto block per concern" do
      expect(content).to include("#### Notes for Publishable")
      concern_end = content.index("<!-- DOCWRIGHT:END:Publishable -->")
      concern_notes = content.index("#### Notes for Publishable")
      expect(concern_notes).to be > concern_end
    end

    it "contains concern file location" do
      expect(content).to include("app/models/concerns/publishable.rb")
      expect(content).to include("app/controllers/concerns/authenticatable.rb")
    end

    it "contains public method names" do
      expect(content).to include("publish")
      expect(content).to include("authenticate!")
    end

    it "shows correct concern type" do
      expect(content).to include("Model Concern")
      expect(content).to include("Controller Concern")
    end

    it "contains included_in class names" do
      expect(content).to include("Post")
      expect(content).to include("UsersController")
    end

    it "detects both model and controller concerns" do
      publishable_section = content[/<!-- DOCWRIGHT:AUTO:Publishable -->.*?<!-- DOCWRIGHT:END:Publishable -->/m]
      authenticatable_section = content[/<!-- DOCWRIGHT:AUTO:Authenticatable -->.*?<!-- DOCWRIGHT:END:Authenticatable -->/m]
      expect(publishable_section).to include("Model Concern")
      expect(authenticatable_section).to include("Controller Concern")
    end

    it "contains correct summary counts" do
      expect(content).to include("Total concerns: 2")
      expect(content).to include("Model concerns: 1")
      expect(content).to include("Controller concerns: 1")
    end

    it "does not have notes slot for _summary block" do
      expect(content).not_to include("### Notes for _summary")
    end

    it "matches concern type with correct file location" do
      publishable_section = content[/<!-- DOCWRIGHT:AUTO:Publishable -->.*?<!-- DOCWRIGHT:END:Publishable -->/m]
      expect(publishable_section).to include("Model Concern")
      expect(publishable_section).to include("app/models/concerns/publishable.rb")

      authenticatable_section = content[/<!-- DOCWRIGHT:AUTO:Authenticatable -->.*?<!-- DOCWRIGHT:END:Authenticatable -->/m]
      expect(authenticatable_section).to include("Controller Concern")
      expect(authenticatable_section).to include("app/controllers/concerns/authenticatable.rb")
    end
  end

  describe "#generate with eager_load_failed" do
    it "skips generation when eager_load_failed is true" do
      Dir.chdir(tmpdir) do
        expect do
          Docwright::Extractors::ConcernsExtractor.new.generate(true)
        end.to output(a_string_including("skipped concerns")).to_stdout
      end

      expect(File.exist?(File.join(tmpdir, "docs", "concerns.md"))).to be false
    end
  end
end
