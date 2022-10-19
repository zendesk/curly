require 'generators/curly/controller/controller_generator'

describe Curly::Generators::ControllerGenerator do
  with_args "animals/cows", "foo"

  it "generates a Curly template for each action" do
    expect(subject).to generate("app/views/animals/cows/foo.html.curly") {|content|
      expected_content = "<h1>Animals::Cows#foo</h1>\n" +
        "<p>Find me in app/views/animals/cows/foo.html.curly</p>\n"

      expect(content).to eq expected_content
    }
  end

  it "generates a Curly presenter for each action" do
    expect(subject).to generate("app/presenters/animals/cows/foo_presenter.rb") {|content|
      expected_content = (<<-RUBY).gsub(/^\s{8}/, "")
        class Animals::Cows::FooPresenter < Curly::Presenter
          # If you need to assign variables to the presenter, you can use the
          # `presents` method.
          #
          #   presents :foo, :bar
          #
          # Any public method defined in a presenter class will be available
          # to the Curly template as a variable. Consider making these methods
          # idempotent.
        end
      RUBY

      expect(content).to eq expected_content
    }
  end
end
