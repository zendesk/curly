class Dashboards::ItemPresenter < Curly::Presenter
  presents :item, :name

  def item
    @item
  end

  def name
    @name
  end
end
