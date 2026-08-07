# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Checker do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:docs_dir) { File.join(tmp_dir, "docs") }

  before do
    FileUtils.mkdir_p(docs_dir)
    Docwright::Checker::REQUIRED_FILES.each do |file|
      File.write(File.join(tmp_dir, file), "# Title\n\nReal content here.")
    end
  end

  after { FileUtils.rm_rf(tmp_dir) }

  describe "#run" do
    it "prints checkmark for all existing required files" do
      Dir.chdir(tmp_dir) do
        expect { Docwright::Checker.new.run }.to output(
          a_string_including("✅ docs/database.md")
        ).to_stdout
      end
    end

    it "prints error for missing required file" do
      File.delete(File.join(tmp_dir, "docs/overview.md"))

      Dir.chdir(tmp_dir) do
        expect do
          Docwright::Checker.new.run
        rescue SystemExit
        end.to output(a_string_including("❌ docs/overview.md — missing")).to_stdout
      end
    end

    it "prints checkmark for optional file when enabled and exists" do
      File.write(File.join(tmp_dir, ".docwright.yml"), "optional_docs:\n  auth_and_permissions: true")
      File.write(File.join(tmp_dir, "docs/auth_and_permissions.md"), "# Auth\n\nReal content.")

      Dir.chdir(tmp_dir) do
        expect { Docwright::Checker.new.run }.to output(
          a_string_including("✅ docs/auth_and_permissions.md")
        ).to_stdout
      end
    end

    it "prints error for optional file when enabled but missing" do
      File.write(File.join(tmp_dir, ".docwright.yml"), "optional_docs:\n  auth_and_permissions: true")

      Dir.chdir(tmp_dir) do
        expect do
          Docwright::Checker.new.run
        rescue SystemExit
        end.to output(
          a_string_including("❌ docs/auth_and_permissions.md — missing (enabled in .docwright.yml)")
        ).to_stdout
      end
    end

    it "skips optional check when .docwright.yml does not exist" do
      Dir.chdir(tmp_dir) do
        expect { Docwright::Checker.new.run }.not_to output(
          a_string_including("optional")
        ).to_stdout
      end
    end

    it "prints warning for placeholder content only files" do
      File.write(File.join(tmp_dir, "docs/overview.md"), "# Overview\n<!-- just a comment -->")

      Dir.chdir(tmp_dir) do
        expect do
          Docwright::Checker.new.run
        rescue SystemExit
        end.to output(
          a_string_including("⚠  docs/overview.md — placeholder content only")
        ).to_stdout
      end
    end

    it "does not warn for files with real content" do
      Dir.chdir(tmp_dir) do
        expect { Docwright::Checker.new.run }.not_to output(
          a_string_including("placeholder content only")
        ).to_stdout
      end
    end

    it "prints warning for empty notes slot but skips _summary" do
      notes_content = "<!-- DOCWRIGHT:AUTO:Post -->\n## Post\n<!-- DOCWRIGHT:END:Post -->\n#### Notes for Post\n<!-- add notes -->\n<!-- DOCWRIGHT:AUTO:_summary -->\n## Summary\n<!-- DOCWRIGHT:END:_summary -->\n### Notes for _summary\n<!-- add notes -->"
      File.write(File.join(tmp_dir, "docs/models.md"), notes_content)

      Dir.chdir(tmp_dir) do
        expect do
          Docwright::Checker.new.run
        rescue SystemExit
        end.to output(
          a_string_including("#### Notes for Post")
        ).to_stdout
      end
    end

    it "has the correct required files defined" do
      expect(Docwright::Checker::REQUIRED_FILES).to include("docs/database.md")
      expect(Docwright::Checker::REQUIRED_FILES).to include("docs/overview.md")
      expect(Docwright::Checker::REQUIRED_FILES.size).to eq(12)
    end
  end
end
