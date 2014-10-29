class Dashboards::NewPresenter < Curly::Presenter
  presents :name

  def form(&block)
    form_for(:dashboard, &block)
  end

  class FormPresenter < Curly::Presenter
    presents :form

    def name_label
      "Name"
    end

    def name_input
      @form.text_field :name
    end
  end
end
