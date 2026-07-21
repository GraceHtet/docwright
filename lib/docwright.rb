# frozen_string_literal: true

require_relative "docwright/version"
require "rails/railtie"
require_relative "docwright/railtie"
require_relative "docwright/merger"
require_relative "docwright/extractors/database_extractor"
require_relative "docwright/extractors/api_extractor"
require_relative "docwright/extractors/model_extractor"
require_relative "docwright/extractors/auth_extractor"
require_relative "docwright/extractors/background_jobs_extractor"
require_relative "docwright/extractors/services_extractor"
require_relative "docwright/extractors/concerns_extractor"
require_relative "docwright/generators/manual_generator"
require_relative "docwright/generators/feature_generator"
require_relative "docwright/wizard"
require_relative "docwright/checker"
require_relative "docwright/searcher"

module Docwright
  class Error < StandardError; end
  # Your code goes here...
end
