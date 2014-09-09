class Dashboards::ItemPresenter < Curly::Presenter
  presents :item

  def item
    @item
  end
end
