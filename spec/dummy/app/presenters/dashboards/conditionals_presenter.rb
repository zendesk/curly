class Dashboards::ConditionalsPresenter < Curly::Presenter
  presents :name

  def bar?
    true
  end
end
