# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Searcher do
  let(:temp_dir) { Dir.mktmpdir }
  let(:docs_dir) { File.join(temp_dir, "docs") }

  before { FileUtils.mkdir_p(docs_dir) }
  after { FileUtils.rm_rf(temp_dir) }

  describe "#run" do
    it "prints usage message when no keyword provided" do
      expect do
        Docwright::Searcher.new("").run
      end.to output(a_string_including("No matches found for")).to_stdout
    end

    it "prints a filename when keyword is found in a file" do
      File.write(File.join(docs_dir, "overview.md"), "# Overview\nThis app handles authentication.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("authentication").run
        end.to output(a_string_including("docs/overview.md")).to_stdout
      end
    end

    it "prints correct line number when keyword is found " do
      File.write(File.join(docs_dir, "overview.md"), "# Overview\nThis app handles authentication.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("authentication").run
        end.to output(a_string_including("Line 2:")).to_stdout
      end
    end

    it "prints results from multiple files" do
      File.write(File.join(docs_dir, "overview.md"), "# Overview\nThis app handles authentication.")
      File.write(File.join(docs_dir, "setup.md"), "# Setup\nConfigure authentication here.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("authentication").run
        end.to output(a_string_including("docs/overview.md").and(a_string_including("docs/setup.md"))).to_stdout
      end
    end

    it "prints no matches message when no keyword is found " do
      File.write(File.join(docs_dir, "overview.md"), "# Overview\nThis app handles authentication.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("nonexistent").run
        end.to output(a_string_including("No matches found for")).to_stdout
      end
    end

    it "searches case insensitivity" do
      File.write(File.join(docs_dir, "overview.md"), "# Overview\nThis app handles authentication.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("Authentication").run
        end.to output(a_string_including("docs/overview.md")).to_stdout
      end
    end

    it "prints total file and match count" do
      File.write(File.join(docs_dir, "overview.md"),
                 "# Overview\nThis app handles authentication. \nAuthentication is important.")

      Dir.chdir(temp_dir) do
        expect do
          Docwright::Searcher.new("Authentication").run
        end.to output(a_string_including("1 file, 2 lines found.")).to_stdout
      end
    end
  end
end
