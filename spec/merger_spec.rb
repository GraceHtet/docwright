# frozen_string_literal: true
# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Merger do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:path) { File.join(tmp_dir, "test.md") }

  after { FileUtils.rm_rf(tmp_dir) }

  describe ".write" do
    context "when file does not exist" do
      it "creates a new file with AUTO markers" do
        Docwright::Merger.write(path, "some content")

        content = File.read(path)
        expect(content).to include("<!-- DOCWRIGHT:AUTO -->")
        expect(content).to include("some content")
        expect(content).to include("<!-- DOCWRIGHT:END -->")
      end
    end

    context "when file already exists" do
      it "replaces AUTO block and preserves content outside" do
        existing = "<!-- DOCWRIGHT:AUTO -->\nold content\n<!-- DOCWRIGHT:END -->\nmy notes"
        File.write(path, existing)

        Docwright::Merger.write(path, "new content")

        content = File.read(path)
        expect(content).to include("new content")
        expect(content).not_to include("old content")
        expect(content).to include("my notes")
      end
    end
  end

  describe ".fresh" do
    it "creates file with AUTO markers wrapping content" do
      Docwright::Merger.fresh(path, "fresh content")

      content = File.read(path)
      expect(content).to eq("<!-- DOCWRIGHT:AUTO -->\nfresh content\n<!-- DOCWRIGHT:END -->")
    end
  end

  describe ".merge" do
    it "replaces AUTO block and preserves content outside" do
      existing = "<!-- DOCWRIGHT:AUTO -->\nold\n<!-- DOCWRIGHT:END -->\nmy notes"
      File.write(path, existing)

      Docwright::Merger.merge(path, "new")

      content = File.read(path)
      expect(content).to include("new")
      expect(content).not_to include("old")
      expect(content).to include("my notes")
    end

    it "leaves file unchanged when no AUTO block exists" do
      File.write(path, "no markers here")

      Docwright::Merger.merge(path, "new content")

      expect(File.read(path)).to eq("no markers here")
    end
  end

  describe ".write_named" do
    context "when file does not exist" do
      it "creates file with named markers and notes placeholder" do
        Docwright::Merger.write_named(path, "Post", "post content", "#### Notes for Post\n<!-- add notes -->")

        content = File.read(path)
        expect(content).to include("<!-- DOCWRIGHT:AUTO:Post -->")
        expect(content).to include("post content")
        expect(content).to include("<!-- DOCWRIGHT:END:Post -->")
        expect(content).to include("#### Notes for Post")
      end
    end

    context "when file already exists" do
      it "replaces only the named block and preserves everything else" do
        existing = "<!-- DOCWRIGHT:AUTO:Post -->\nold post\n<!-- DOCWRIGHT:END:Post -->\n#### Notes for Post\nmy post notes"
        File.write(path, existing)

        Docwright::Merger.write_named(path, "Post", "new post", "#### Notes for Post")

        content = File.read(path)
        expect(content).to include("new post")
        expect(content).not_to include("old post")
        expect(content).to include("my post notes")
      end
    end
  end

  describe ".fresh_named" do
    it "creates file with named markers and notes placeholder" do
      Docwright::Merger.fresh_named(path, "User", "user content", "#### Notes for User\n<!-- add notes -->")

      content = File.read(path)
      expect(content).to include("<!-- DOCWRIGHT:AUTO:User -->")
      expect(content).to include("user content")
      expect(content).to include("<!-- DOCWRIGHT:END:User -->")
      expect(content).to include("#### Notes for User")
    end

    it "writes empty notes section when notes_placeholder is empty" do
      Docwright::Merger.fresh_named(path, "_summary", "summary content", "")

      content = File.read(path)
      expect(content).to include("<!-- DOCWRIGHT:AUTO:_summary -->")
      expect(content).not_to include("#### Notes for")
    end
  end

  describe ".merge_named" do
    it "replaces existing named block and preserves content outside" do
      existing = "<!-- DOCWRIGHT:AUTO:Post -->\nold\n<!-- DOCWRIGHT:END:Post -->\n#### Notes for Post\nmy notes"
      File.write(path, existing)

      Docwright::Merger.merge_named(path, "Post", "new", "#### Notes for Post")

      content = File.read(path)
      expect(content).to include("new")
      expect(content).not_to include("old")
      expect(content).to include("my notes")
    end

    it "appends new named block when it does not exist" do
      File.write(path, "existing content")

      Docwright::Merger.merge_named(path, "User", "user content", "#### Notes for User")

      content = File.read(path)
      expect(content).to include("existing content")
      expect(content).to include("<!-- DOCWRIGHT:AUTO:User -->")
      expect(content).to include("user content")
      expect(content).to include("#### Notes for User")
    end
  end
end
