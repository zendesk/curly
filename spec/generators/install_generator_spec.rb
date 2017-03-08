require 'genspec'
require 'generators/curly/install/install_generator'

describe Curly::Generators::InstallGenerator do
  with_args %w()

  it "generates a Curly template for the application layout" do
    expect(subject).to call_action(:remove_file, "app/views/layouts/application.html.erb")
    expect(subject).to generate("app/views/layouts/application.html.curly") {|content|
      expect(content).to include "<title>Dummy</title>"
      expect(content).to include "{{csrf_meta_tags}}"
      expect(content).to include "{{stylesheet_links}}"
      expect(content).to include "{{javascript_links}}"
      expect(content).to include "{{yield}}"
    }
  end
  it "generates a Curly presenter for the form view" do
    expect(subject).to generate("app/presenters/layouts/application_presenter.rb") {|content|
      expect(content).to include "class Layouts::ApplicationPresenter < Curly::Presenter" 
      expect(content).to include "exposes_helper :csrf_meta_tags" 
      expect(content).to include "def stylesheet_links" 
      expect(content).to include "def javascript_links" 
    }
  end
end
