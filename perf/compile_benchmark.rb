require 'bundler/setup'
require 'benchmark/ips'

ENV["RAILS_ENV"] = "test"

require_relative '../spec/dummy/config/environment'

class TestPresenter < Curly::Presenter
  def foo
  end

  def bar
  end

  def form(&block)
    xcontent_tag :form, block.call
  end

  class FormPresenter < Curly::Presenter
    def fields
      %w[]
    end

    class FieldPresenter < Curly::Presenter
      presents :field

      def field_name
        @field
      end
    end
  end
end

# Build a huge template.
TEMPLATE = <<-CURLY
<h1>{{foo}}</h1>
<h2>{{bar}}</h2>

{{@form}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
  {{*fields}}
    <input name={{field_name}}><br>
  {{/fields}}
{{/form}}
CURLY

Benchmark.ips do |x|
  x.report "compiling a huge template" do
    Curly::Compiler.compile(TEMPLATE * 100, TestPresenter)
  end

  x.report "compiling a normal template" do
    Curly::Compiler.compile(TEMPLATE, TestPresenter)
  end

  x.compare!
end
