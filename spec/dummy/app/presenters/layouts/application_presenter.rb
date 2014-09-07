class Layouts::ApplicationPresenter < Curly::Presenter
  def title
    "Dummy app"
  end

  def content
    yield
  end
end
