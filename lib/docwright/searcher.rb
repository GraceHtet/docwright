# frozen_string_literal: true

module Docwright
  class Searcher
    def initialize(term)
      @term = term
    end

    def run
      puts "\nDocWright Search: \"#{@term}\""
      puts "===================================\n\n"

      results = search_docs
      print_results(results)
    end

    private

    def search_docs
      md_files = Dir.glob("docs/**/*.md")
      results = {}

      md_files.each do |file|
        matches = []
        File.readlines(file).each_with_index do |line, i|
          matches << { line_number: i + 1, content: line.chomp } if line.downcase.include?(@term.downcase)
        end

        results[file] = matches if matches.any?
      end

      results
    end

    def print_results(results)
      if results.empty?
        puts "No matches found for \"#{@term}\""
        return
      end

      total_matches = 0

      results.each do |file, matches|
        puts file
        matches.each do |match|
          puts "Line #{match[:line_number]}: #{match[:content].strip}"
          total_matches += 1
        end
        puts ""
      end

      puts "#{results.size} #{"file".pluralize(results.size)}, #{total_matches} #{"match".pluralize(total_matches)} found."
    end
  end
end
