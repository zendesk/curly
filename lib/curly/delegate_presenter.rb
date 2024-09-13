require 'curly/presenter'

module Curly
  class DelegatePresenter < Curly::Presenter
    def self.delegates(*methods)
      methods.each do |method|
        class_eval <<-RUBY
          def #{method}
            @#{delegatee_name}.#{method}
          end
        RUBY
      end
    end

    def self.inherited(subclass)
      self.presented_names += [subclass.delegatee_name]
    end

    def self.delegatee_name
      name.split("::").last.underscore.sub(/_presenter$/, "")
    end
  end
end
