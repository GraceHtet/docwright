# frozen_string_literal: true

module Docwright
  module Extractors
    class BackgroundJobsExtractor
      INTERNAL_JOBS = %w[ApplicationJob].freeze

      def generate
        Rails.application.eager_load!

        jobs = find_jobs
        if jobs.empty?
          puts "DocWright: no background jobs found — skipping background_jobs.md"
          return
        end

        priorities = load_queue_priorities
        schedules = load_schedules

        FileUtils.mkdir_p("docs")

        jobs.each do |job|
          lines = build_job_lines(job, priorities, schedules)
          notes = "#### Notes for #{job.name}\n<!-- Describe what triggers this job, retry behavior, dependencies -->"
          Docwright::Merger.write_named("docs/background_jobs.md", job.name, lines.join("\n"), notes)
        end

        summary_lines = build_summary_lines(jobs, priorities, schedules)
        Docwright::Merger.write_named("docs/background_jobs.md", "_summary", summary_lines.join("\n"), "")

        puts "DocWright: wrote docs/background_jobs.md"
      rescue NameError => e
        raise unless e.message.include?("ActiveJob")

        puts "DocWright: skipped background_jobs.md — ActiveJob is not loaded."
        puts "  To enable: uncomment 'require \"active_job/railtie\"' in config/application.rb"
      end

      private

      def find_jobs
        ActiveJob::Base.descendants
                       .reject { |j| INTERNAL_JOBS.include?(j.name) }
                       .reject { |j| j.name.nil? }
                       .sort_by(&:name)
      end

      def load_queue_priorities
        path = "config/sidekiq.yml"
        return {} unless File.exist?(path)

        require "yaml"
        config = YAML.load_file(path)
        return {} unless config.is_a?(Hash)

        queues = config[:queues] || config["queues"] || []
        queues.each_with_object({}) do |entry, hash|
          hash[entry[0].to_s] = entry[1]
        end
      end

      def load_schedules
        schedules = {}
        schedules.merge!(load_whenever_schedules)
        schedules.merge!(load_solid_queue_schedules)
        schedules
      end

      def load_whenever_schedules
        path = "config/schedule.rb"
        return {} unless File.exist?(path)

        schedules = {}
        current_schedule = nil
        File.readlines(path).each do |line|
          if line =~ /every\s+(.+)\s+do/
            current_schedule = ::Regexp.last_match(1).strip
          elsif line =~ /runner\s+["'](.+Job)/
            job_name = ::Regexp.last_match(1).strip
            schedules[job_name] = current_schedule if current_schedule
          end
        end

        schedules
      end

      def load_solid_queue_schedules
        path = "config/recurring.yml"
        return {} unless File.exist?(path)

        require "yaml"
        config = YAML.load_file(path)
        return {} unless config.is_a?(Hash)

        config.each_with_object({}) do |(_, v), hash|
          hash[v["class"]] = v["schedule"] if v["class"] && v["schedule"]
        end
      end

      def build_job_lines(job, priorities, schedules)
        queue = job.queue_name.to_s
        priority = priorities[queue]
        queue_display = priority ? "#{queue} (priority: #{priority})" : queue
        schedule = schedules[job.name] || "not scheduled"
        path = "app/jobs/#{job.name.underscore}.rb"

        lines = []
        lines << "#### #{job.name}"
        lines << "- Queue: #{queue_display}"
        lines << "- Schedule: #{schedule}"
        lines << "- Defined in: #{path}"
        lines
      end

      def build_summary_lines(jobs, priorities, schedules)
        scheduled = jobs.select { |j| schedules.key?(j.name) }
        unscheduled = jobs.reject { |j| schedules.key?(j.name) }
        queues_used = jobs.map(&:queue_name).map(&:to_s).uniq.sort

        lines = ["### Background Jobs Summary\n"]

        unless priorities.empty?
          lines << "### Queue priorities (from config/sidekiq.yml)"
          priorities.each { |q, p| lines << "- #{q} — priority: #{p}" }
          lines << ""
        end

        unless scheduled.empty?
          lines << "### Scheduled jobs"
          scheduled.each { |j| lines << "- #{j.name} — #{schedules[j.name]}" }
          lines << ""
        end

        unless unscheduled.empty?
          lines << "### Unscheduled jobs"
          unscheduled.each { |j| lines << "- #{j.name}" }
          lines << ""
        end

        lines << "### Summary"
        lines << "- Total jobs: #{jobs.size}"
        lines << "- Queues used: #{queues_used.join(", ")}"
        lines << "- Scheduled: #{scheduled.size}"
        lines << "- Unscheduled: #{unscheduled.size}"
        lines
      end
    end
  end
end
