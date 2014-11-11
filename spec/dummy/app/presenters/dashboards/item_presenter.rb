class Dashboards::ItemPresenter < Curly::Presenter
  presents :item, :name

  def item
    @item
  end

  def name
    @name
  end

  def subitems
    %w[1 2 3]
  end

  class SubitemPresenter < Curly::Presenter
    presents :item, :subitem

    def name
      @subitem
    end
  end
end
