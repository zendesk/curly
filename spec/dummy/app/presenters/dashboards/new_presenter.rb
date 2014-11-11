class Dashboards::NewPresenter < Curly::Presenter
  presents :name

  def form(&block)
    form_for(:dashboard, &block)
  end

  class FormPresenter < Curly::Presenter
    presents :form, :name

    def name_field(&block)
      content_tag :div, class: "field" do
        block.call
      end
    end

    class NameFieldPresenter < Curly::Presenter
      presents :form, :name

      def label
        "Name"
      end

      def input
        @form.text_field :name, value: @name
      end
    end
  end
end
