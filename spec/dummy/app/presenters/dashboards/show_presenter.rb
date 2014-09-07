class Dashboards::ShowPresenter < Curly::Presenter
  presents :message

  def message
    @message
  end

  def welcome
    # This is a helper method:
    welcome_message
  end
end
