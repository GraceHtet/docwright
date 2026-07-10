# frozen_string_literal: true

RSpec.describe Docwright do
  it "has a version number" do
    expect(Docwright::VERSION).not_to be_nil
  end

  it "has a Railtie" do
    expect(Docwright::Railtie.ancestors).to include(Rails::Railtie)
  end
end
