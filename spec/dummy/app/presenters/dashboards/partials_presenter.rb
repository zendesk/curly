class Dashboards::PartialsPresenter < Curly::Presenter
  def items
    render partial: 'item', collection: ["One", "Two"]
  end
end
