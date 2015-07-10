require 'rspec/rails'

module Curly
  module RSpec
    module PresenterExampleGroup
      extend ActiveSupport::Concern
      include ::RSpec::Rails::ViewExampleGroup

      included do
        let(:presenter) { described_class.new(view, view_assigns) }
      end
    end

    ::RSpec.configuration.include PresenterExampleGroup, type: :presenter
  end
end
