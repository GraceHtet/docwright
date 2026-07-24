# frozen_string_literal: true

module Docwright
  class Merger
    AUTO_START = "<!-- DOCWRIGHT:AUTO -->"
    AUTO_END = "<!-- DOCWRIGHT:END -->"

    def self.write(path, auto_content)
      if File.exist?(path)
        merge(path, auto_content)
      else
        fresh(path, auto_content)
      end
    end

    def self.write_named(path, name, auto_content, notes_placeholder)
      if File.exist?(path)
        merge_named(path, name, auto_content, notes_placeholder)
      else
        fresh_named(path, name, auto_content, notes_placeholder)
      end
    end

    def self.fresh(path, auto_content)
      content = "#{AUTO_START}\n#{auto_content}\n#{AUTO_END}"
      File.write(path, content)
    end

    def self.fresh_named(path, name, auto_content, notes_placeholder)
      content = ""
      content += "<!-- DOCWRIGHT:AUTO:#{name} -->\n"
      content += "#{auto_content}\n"
      content += "<!-- DOCWRIGHT:END:#{name} -->\n"
      content += "#{notes_placeholder}\n"
      File.write(path, content)
    end

    def self.merge(path, auto_content)
      existing = File.read(path)
      replacement = "#{AUTO_START}\n#{auto_content}\n#{AUTO_END}"
      updated = existing.gsub(/#{Regexp.escape(AUTO_START)}.*?#{Regexp.escape(AUTO_END)}/m, replacement)
      File.write(path, updated)
    end

    def self.merge_named(path, name, auto_content, notes_placeholder)
      existing = File.read(path)
      start_marker = "<!-- DOCWRIGHT:AUTO:#{name} -->"
      end_marker = "<!-- DOCWRIGHT:END:#{name} -->"
      replacement = "#{start_marker}\n#{auto_content}\n#{end_marker}"

      updated = if existing.include?(start_marker)
                  existing.gsub(/#{Regexp.escape(start_marker)}.*?#{Regexp.escape(end_marker)}/m, replacement)
                else
                  existing + "\n#{replacement}\n#{notes_placeholder}\n"
                end
      File.write(path, updated)
    end
  end
end
