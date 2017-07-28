require 'genspec'
require 'generators/curly/scaffold/scaffold_generator'

describe Curly::Generators::ScaffoldGenerator do
  with_args %w(article title body published:boolean)

  it "generates a Curly presenter for the index view" do
    expect(subject).to generate("app/presenters/articles/index_presenter.rb") {|content|
      expect(content).to include "class Articles::IndexPresenter < Curly::Presenter"
      expect(content).to include "presents :articles"
      expect(content).to include "def articles"
      expect(content).to include "def notice_text"
      expect(content).to include "def create_link"
      expect(content).to include "class ArticlePresenter < Curly::Presenter"
      expect(content).to include "def title"
      expect(content).to include "def body"
      expect(content).to include "def published"
    }
  end
  it "generates a Curly presenter for the show view" do
    expect(subject).to generate("app/presenters/articles/show_presenter.rb") {|content|
      expect(content).to include "class Articles::ShowPresenter < Curly::Presenter"
      expect(content).to include "presents :article"
      expect(content).to include "def article"
      expect(content).to include "def notice_text"
      expect(content).to include "def articles_link"
      expect(content).to include "class ArticlePresenter < Curly::Presenter"
      expect(content).to include "def title"
      expect(content).to include "def body"
      expect(content).to include "def published"
    }
  end
  it "generates a Curly presenter for the new view" do
    expect(subject).to generate("app/presenters/articles/new_presenter.rb") {|content|
      expect(content).to include "class Articles::NewPresenter < Curly::Presenter"
      expect(content).to include "presents :article"
      expect(content).to include "def article_form"
      expect(content).to include "render 'form', article: @article"
      expect(content).to include "def articles_link"
    }
  end
  it "generates a Curly presenter for the edit view" do
    expect(subject).to generate("app/presenters/articles/edit_presenter.rb") {|content|
      expect(content).to include "class Articles::EditPresenter < Curly::Presenter"
      expect(content).to include "presents :article"
      expect(content).to include "def article"
      expect(content).to include "def article_form"
      expect(content).to include "render 'form', article: @article"
      expect(content).to include "def articles_link"
    }
  end
  it "generates a Curly presenter for the form view" do
    expect(subject).to generate("app/presenters/articles/form_presenter.rb") {|content|
      expect(content).to include "class Articles::FormPresenter < Curly::Presenter"
      expect(content).to include "presents :article"
      expect(content).to include "def article_errors"
      expect(content).to include "def article_form(&block)"
      expect(content).to include "def submit"
      expect(content).to include "class ArticleFormPresenter < Curly::Presenter"
      expect(content).to include "class ArticleErrorsPresenter < Curly::Presenter"
      expect(content).to include "class ErrorMessagePresenter < Curly::Presenter"
    }
  end
end
