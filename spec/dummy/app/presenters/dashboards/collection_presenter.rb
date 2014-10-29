class Dashboards::CollectionPresenter < Curly::Presenter
  presents :items

  def items
    @items
  end
end
