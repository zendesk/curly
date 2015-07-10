ENV["RAILS_ENV"] = "test"
require_relative '../../../config/environment'
require 'curly/rspec'

describe Dashboards::ShowPresenter, type: :presenter do
  describe "#message" do
    it "returns the message" do
      assign :message, "Hello, World!"
      expect(presenter.message).to eq "Hello, World!"
    end
  end
end
