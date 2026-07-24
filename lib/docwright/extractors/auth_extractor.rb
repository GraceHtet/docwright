# frozen_string_literal: true

module Docwright
  module Extractors
    class AuthExtractor # rubocop:disable Style/Documentation
      CALLBACK_KINDS = %i[before around after].freeze
      def generate
        begin
          Rails.application.eager_load!
        rescue NameError => e
          puts "DocWright: warning — could not eager load all files: #{e.message}"
        end

        controllers = find_controllers
        filter_map = build_filter_map(controllers)
        unprotected = find_unprotected(controllers)

        lines = build_lines(filter_map, unprotected, controllers)

        FileUtils.mkdir_p("docs")
        Docwright::Merger.write("docs/auth_and_permissions.md", lines.join("\n"))
        puts "DocWright: wrote docs/auth_and_permissions.md"
      end

      private

      def find_controllers
        ActionController::Base.descendants
                              .reject { |c| c.abstract? rescue false } # rubocop:disable Style/RescueModifier
                              .reject { |c| c.name.nil? }
                              .reject { |c| c.name.start_with?("ActionController", "ActiveStorage", "Rails") }
                              .sort_by(&:name)
      end

      def build_filter_map(controllers) # rubocop:disable Metrics/MethodLength
        filter_map = {}

        controllers.each do |controller|
          CALLBACK_KINDS.each do |kind|
            before_actions = controller._process_action_callbacks.select { |cb| cb.kind == kind }

            before_actions.each do |cb|
              filter_name = cb.filter.to_s
              next if cb.filter.is_a?(Proc)
              next if filter_name.start_with?("verify_authenticity_token", "verify_same_origin_request")

              filter_map[filter_name] ||= { kind: kind, usages: [] }
              filter_map[filter_name][:usages] << {
                controller: controller.name,
                callback: cb
              }
            end
          end
        end

        filter_map
      end

      def find_unprotected(controllers)
        controllers.select do |controller|
          controller._process_action_callbacks.none? { |cb| cb.kind == :before }
        end
      end

      def build_lines(filter_map, unprotected, controllers) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        lines = ["# Authentication & Permissions\n"]

        CALLBACK_KINDS.each do |kind|
          kind_filters = filter_map.select { |_, v| v[:kind] == kind }
          next if kind_filters.empty?

          lines << "## #{kind.to_s.capitalize} Action Filters\n"

          kind_filters.each do |filter_name, data|
            lines << "### #{filter_name}"
            defined_in = detect_origin(filter_name)
            lines << "- Defined in: #{defined_in}" if defined_in

            data[:usages].each do |usage|
              conditions = format_conditions(usage[:callback])
              lines << "- Applied to: #{usage[:controller]}#{conditions}"
            end
            lines << ""
          end
        end

        unless unprotected.empty?
          lines << "## Unprotected Controllers\n"
          unprotected.each do |c|
            lines << "- #{c.name} — no before_action filters detected"
          end
          lines << ""
        end

        lines << "## Summary\n"
        lines << "- Total controllers: #{controllers.size}"
        lines << "- Protected: #{controllers.size - unprotected.size}"
        lines << "- Unprotected: #{unprotected.size}"

        lines
      end

      def detect_origin(filter_name)
        "ApplicationController" if ApplicationController.method_defined?(filter_name.to_sym)
      rescue NameError
        nil
      end

      def format_conditions(cb)
        conditions = cb.instance_variable_get(:@if) || []
        parts = []

        conditions.each do |condition|
          next unless condition.class.name.to_s.include?("ActionFilter")

          key = condition.instance_variable_get(:@conditional_key)
          actions = condition.instance_variable_get(:@actions).to_a
          parts << "#{key}: #{actions.join(", ")}" if actions.any?
        end

        parts.empty? ? "" : " (#{parts.join(", ")})"
      end
    end
  end
end
