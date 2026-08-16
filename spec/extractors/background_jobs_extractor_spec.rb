# frozen_string_literal: true

require "rails_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Docwright::Extractors::BackgroundJobsExtractor do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe "#generate" do
    before do
      FileUtils.mkdir_p(File.join(tmpdir, "config"))
      File.write(File.join(tmpdir, "config", "sidekiq.yml"), ":queues:\n  - [default, 2]\n  - [mailers, 1]")
      Dir.chdir(tmpdir) do
        Docwright::Extractors::BackgroundJobsExtractor.new.generate
      end
    end

    let(:content) { File.read(File.join(tmpdir, "docs", "background_jobs.md")) }

    it "generates docs/background_jobs.md file" do
      expect(File.exist?(File.join(tmpdir, "docs", "background_jobs.md"))).to be true
    end

    it "contains job class names" do
      expect(content).to include("TestJob")
      expect(content).to include("AnotherJob")
    end

    it "contains named AUTO markers per job" do
      expect(content).to include("<!-- DOCWRIGHT:AUTO:TestJob -->")
      expect(content).to include("<!-- DOCWRIGHT:END:TestJob -->")
      expect(content).to include("<!-- DOCWRIGHT:AUTO:AnotherJob -->")
      expect(content).to include("<!-- DOCWRIGHT:END:AnotherJob -->")
    end

    it "has notes slot outside auto block per job" do
      expect(content).to include("#### Notes for TestJob")
      test_job_end = content.index("<!-- DOCWRIGHT:END:TestJob -->")
      test_job_notes = content.index("#### Notes for TestJob")
      expect(test_job_notes).to be > test_job_end
    end

    it "contains queue names" do
      expect(content).to include("default")
      expect(content).to include("mailers")
    end

    it "contains queue priorities from sidekiq.yml" do
      expect(content).to include("priority: 2")
      expect(content).to include("priority: 1")
    end

    it "contains unscheduled jobs in summary" do
      expect(content).to include("### Unscheduled jobs")
      expect(content).to include("- TestJob")
      expect(content).to include("- AnotherJob")
    end

    it "contains summary counts" do
      expect(content).to include("### Summary")
      expect(content).to include("Total jobs: 2")
      expect(content).to include("Scheduled: 0")
      expect(content).to include("Unscheduled: 2")
    end
  end

  describe "#generate with eager_load_failed" do
    it "skipped when eager_load_fails" do
      Dir.chdir(tmpdir) do
        expect do
          Docwright::Extractors::BackgroundJobsExtractor.new.generate(true)
        end.to output(a_string_including("skipped background_jobs")).to_stdout
      end

      expect(File.exist?(File.join(tmpdir, "docs", "background_jobs.md"))).to be false
    end
  end
end
