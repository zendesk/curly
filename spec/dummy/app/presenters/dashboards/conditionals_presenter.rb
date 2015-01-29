class Dashboards::ConditionalsPresenter < Curly::Presenter
  presents :name

  def bar?
    true
  end

  def nobar?
    false
  end

  def ifmethod
    "foo 6"
  end

  def methodif
    "foo 7"
  end

  def elsemethod
    "foo 8"
  end

  def methodelse
    "foo 9"
  end
end
