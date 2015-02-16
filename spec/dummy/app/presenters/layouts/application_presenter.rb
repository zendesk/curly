class Layouts::ApplicationPresenter < Curly::Presenter
  def title
    "Dummy app"
  end

  def content
    yield
  end

  def header(&block)
    block.call
  end

  class HeaderPresenter < Curly::Presenter

    def title
      "Dummy app"
    end
  end

end
