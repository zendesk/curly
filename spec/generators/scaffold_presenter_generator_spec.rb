require 'genspec'
require 'generators/curly/scaffold/scaffold_generator'

describe Curly::Generators::ScaffoldGenerator do
  with_args %w(post title body published:boolean)

  it "generates a Curly presenter for the index view" do
    expect(subject).to generate("app/presenters/posts/index_presenter.rb") {|content|
      expect(content).to include "class Posts::IndexPresenter < Curly::Presenter" 
      expect(content).to include "presents :posts" 
      expect(content).to include "def posts" 
      expect(content).to include "def notice_text" 
      expect(content).to include "def create_link" 
      expect(content).to include "class PostPresenter < Curly::Presenter" 
      expect(content).to include "def title" 
      expect(content).to include "def body" 
      expect(content).to include "def published" 
    }
  end
  it "generates a Curly presenter for the show view" do
    expect(subject).to generate("app/presenters/posts/show_presenter.rb") {|content|
      expect(content).to include "class Posts::ShowPresenter < Curly::Presenter" 
      expect(content).to include "presents :post" 
      expect(content).to include "def post" 
      expect(content).to include "def notice_text" 
      expect(content).to include "def posts_link" 
      expect(content).to include "class PostPresenter < Curly::Presenter" 
      expect(content).to include "def title" 
      expect(content).to include "def body" 
      expect(content).to include "def published" 
    }
  end
  it "generates a Curly presenter for the new view" do
    expect(subject).to generate("app/presenters/posts/new_presenter.rb") {|content|
      expect(content).to include "class Posts::NewPresenter < Curly::Presenter" 
      expect(content).to include "presents :post" 
      expect(content).to include "def post_form" 
      expect(content).to include "render 'form', post: @post" 
      expect(content).to include "def posts_link" 
    }
  end
  it "generates a Curly presenter for the edit view" do
    expect(subject).to generate("app/presenters/posts/edit_presenter.rb") {|content|
      expect(content).to include "class Posts::EditPresenter < Curly::Presenter" 
      expect(content).to include "presents :post" 
      expect(content).to include "def post" 
      expect(content).to include "def post_form" 
      expect(content).to include "render 'form', post: @post" 
      expect(content).to include "def posts_link" 
    }
  end
  it "generates a Curly presenter for the form view" do
    expect(subject).to generate("app/presenters/posts/form_presenter.rb") {|content|
      expect(content).to include "class Posts::FormPresenter < Curly::Presenter" 
      expect(content).to include "presents :post" 
      expect(content).to include "def post_errors" 
      expect(content).to include "def post_form(&block)" 
      expect(content).to include "def submit" 
      expect(content).to include "class PostFormPresenter < Curly::Presenter" 
      expect(content).to include "class PostErrorsPresenter < Curly::Presenter" 
      expect(content).to include "class ErrorMessagePresenter < Curly::Presenter" 
    }
  end
end
