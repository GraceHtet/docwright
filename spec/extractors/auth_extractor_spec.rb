# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::AuthExtractor do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe "#generate" do
    before do
      Dir.chdir(tmpdir) do
        Docwright::Extractors::AuthExtractor.new.generate
      end
    end

    let(:content) { File.read(File.join(tmpdir, "docs", "auth_and_permissions.md")) }

    it "generates docs/auth_and_permissions.md file" do
      expect(File.exist?(File.join(tmpdir, "docs", "auth_and_permissions.md"))).to be true
    end

    it "contains before_action filter names" do
      expect(content).to include("authenticate_user!")
      expect(content).to include("set_post")
    end

    it "contains controller names" do
      expect(content).to include("UsersController")
      expect(content).to include("PostsController")
    end

    it "skips Proc callbacks" do
      expect(content).not_to include("#<Proc:")
    end

    it "skips Rails internal filters" do
      expect(content).not_to include("verify_authenticity_token")
      expect(content).not_to include("verify_same_origin_request")
    end

    it "wraps content in AUTO markers" do
      expect(content).to include("<!-- DOCWRIGHT:AUTO -->")
      expect(content).to include("<!-- DOCWRIGHT:END -->")
    end

    it "generate action filter counts" do
      expect(content).to include("Total controllers: 2")
      expect(content).to include("Protected: 2")
      expect(content).to include("Unprotected: 0")
    end
  end

  describe "#generate with eager_load_failed" do
    it "skipped when eager_load_fails" do
      Dir.chdir(tmpdir) do
        expect do
          Docwright::Extractors::AuthExtractor.new.generate(true)
        end.to output(a_string_including("skipped auth_and_permission")).to_stdout
      end

      expect(File.exist?(File.join(tmpdir, "docs", "auth_and_permissions.md"))).to be false
    end
  end
end
