# frozen_string_literal: true

require_relative "docwright/version"
require "rails/railtie"
require_relative "docwright/railtie"

module Docwright
  class Error < StandardError; end
  # Your code goes here...
end
