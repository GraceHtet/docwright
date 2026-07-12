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

    def self.fresh(path, auto_content)
      content = "#{AUTO_START}\n#{auto_content}\n#{AUTO_END}"
      File.write(path, content)
    end

    def self.merge(path, auto_content)
      existing = File.read(path)
      replacement = "#{AUTO_START}\n#{auto_content}\n#{AUTO_END}"
      updated = existing.gsub(/#{Regexp.escape(AUTO_START)}.*?#{Regexp.escape(AUTO_END)}/m, replacement)
      File.write(path, updated)
    end
  end
end
