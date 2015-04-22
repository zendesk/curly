require 'bundler/setup'
require 'benchmark/ips'

ENV["RAILS_ENV"] = "test"

require_relative '../spec/dummy/config/environment'

class TestPresenter < Curly::Presenter
  def hello_with_delegation
    some_helper
  end

  def hello_without_delegation
    not_some_helper
  end

  private

  def not_some_helper
  end
end

class TestContext
  def some_helper
  end
end

context = TestContext.new
presenter = TestPresenter.new(context)

Benchmark.ips do |x|
  x.report "presenter method that delegates to the view context" do
    presenter.hello_with_delegation
  end

  x.report "presenter method that doesn't delegate to the view context" do
    presenter.hello_without_delegation
  end

  x.compare!
end
