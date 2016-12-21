module Curly
  class DependencyTracker
    def self.call(path, template)
      presenter = Curly::Presenter.presenter_for_path(path)
      presenter.dependencies.to_a
    end
  end
end
