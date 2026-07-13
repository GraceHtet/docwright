# frozen_string_literal: true

require_relative "docwright/version"
require "rails/railtie"
require_relative "docwright/railtie"
require_relative "docwright/merger"
require_relative "docwright/extractors/database_extractor"
require_relative "docwright/extractors/api_extractor"
require_relative "docwright/extractors/model_extractor"
module Docwright
  class Error < StandardError; end
  # Your code goes here...
end
