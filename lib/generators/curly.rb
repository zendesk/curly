require "rails/generators/named_base"

module Curly # :nodoc:
  module Generators # :nodoc:
    class Base < Rails::Generators::NamedBase #:nodoc:
      private

        def formats
          [format]
        end

        def format
          :html
        end

        def handler
          :curly
        end
    end
  end
end