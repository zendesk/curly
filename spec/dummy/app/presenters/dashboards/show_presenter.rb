class Dashboards::ShowPresenter < Curly::Presenter
  presents :message

  def message
    @message
  end
end
