class Dashboards::CollectionPresenter < Curly::Presenter
  presents :items, :name

  def items
    @items
  end
end
