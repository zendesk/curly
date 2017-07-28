require 'genspec'
require 'generators/curly/scaffold/scaffold_generator'

describe Curly::Generators::ScaffoldGenerator do
  with_args %w(article title body published:boolean)

  it "generates an Curly template for the index view" do
    expect(subject).to generate("app/views/articles/index.html.curly") {|content|
      expect(content).to include "<th>Body</th>"
      expect(content).to include "<th>Title</th>"
      expect(content).to include "<th>Published</th>"
      expect(content).to include "{{*articles}}"
      # Consistantly not have spaces between curlys.
      expect(content).to include "{{show_link}}"
      expect(content).to include "{{edit_link}}"
      expect(content).to include "{{notice_text}}"
      expect(content).to include "{{destroy_link}}"
      expect(content).to include "{{title}}"
      expect(content).to include "{{body}}"
      expect(content).to include "{{published}}"
    }
  end
  it "generates an Curly template for the show view" do
    expect(subject).to generate("app/views/articles/show.html.curly") {|content|
      expect(content).to include "{{*article}}"
      expect(content).to include "<strong>Title:</strong>"
      expect(content).to include "{{title}}"
      expect(content).to include "<strong>Body:</strong>"
      expect(content).to include "{{body}}"
      expect(content).to include "<strong>Published:</strong>"
      expect(content).to include "{{published}}"
      expect(content).to include "{{articles_link}}"
    }
  end
  it "generates an Curly template for the new view" do
    expect(subject).to generate("app/views/articles/new.html.curly") {|content|
      expect(content).to include "<h1>New Article</h1>"
      expect(content).to include "{{article_form}}"
    }
  end
  it "generates an Curly template for the edit view" do
    expect(subject).to generate("app/views/articles/edit.html.curly") {|content|
      expect(content).to include "<h1>Editing Article</h1>"
      expect(content).to include "{{article_form}}"
    }
  end
  it "generates an Curly template for the form view" do
    expect(subject).to generate("app/views/articles/_form.html.curly") {|content|
      expect(content).to include "{{@article_form}}"
      expect(content).to include "{{#article_errors:any?}}"
      expect(content).to include "{{label.title}}"
      expect(content).to include "{{label.body}}"
      expect(content).to include "{{label.published}}"
      expect(content).to include "{{submit}}"
    }
  end
end
