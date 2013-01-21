require 'spec_helper'
require 'active_support/core_ext/string/output_safety'
require 'active_support/core_ext/hash'
require 'curly/template_handler'

describe Curly::TemplateHandler do
  let :presenter_class do
    Class.new do
      def initialize(context, options = {})
        @context = context
        @cache_key = options.fetch(:cache_key, nil)
        @cache_duration = options.fetch(:cache_duration, nil)
      end

      def foo
        "FOO"
      end

      def bar
        @context.bar
      end

      def cache_key
        @cache_key
      end

      def cache_duration
        @cache_duration
      end

      def method_available?(method)
        true
      end
    end
  end

  let :context_class do
    Class.new do
      attr_reader :output_buffer
      attr_reader :local_assigns, :assigns

      def initialize
        @cache = Hash.new
        @local_assigns = Hash.new
        @assigns = Hash.new
        @clock = 0
      end

      def advance_clock(duration)
        @clock += duration
      end

      def cache(key, options = {})
        fragment, expired_at = @cache[key]

        if fragment.nil? || @clock >= expired_at
          old_buffer = @output_buffer
          @output_buffer = ActiveSupport::SafeBuffer.new

          yield

          fragment = @output_buffer.to_s
          duration = options[:expires_in] || Float::INFINITY

          @cache[key] = [fragment, @clock + duration]

          @output_buffer = old_buffer
        end

        safe_concat(fragment)

        nil
      end

      def safe_concat(str)
        @output_buffer.safe_concat(str)
      end
    end
  end

  let(:template) { double("template", virtual_path: "test") }
  let(:context) { context_class.new }

  before do
    stub_const("TestPresenter", presenter_class)
  end

  it "passes in the presenter context to the presenter class" do
    context.stub(:bar) { "BAR" }
    template.stub(:source) { "{{bar}}" }
    output.should == "BAR"
  end

  it "allows calling public methods on the presenter" do
    template.stub(:source) { "{{foo}}" }
    output.should == "FOO"
  end

  it "marks its output as HTML safe" do
    template.stub(:source) { "{{foo}}" }
    output.should be_html_safe
  end

  context "caching" do
    before do
      template.stub(:source) { "{{bar}}" }
      context.stub(:bar) { "BAR" }
    end

    it "caches the result with the #cache_key from the presenter" do
      context.assigns[:cache_key] = "x"
      output.should == "BAR"

      context.stub(:bar) { "BAZ" }
      output.should == "BAR"

      context.assigns[:cache_key] = "y"
      output.should == "BAZ"
    end

    it "doesn't cache when the cache key is nil" do
      context.assigns[:cache_key] = nil
      output.should == "BAR"

      context.stub(:bar) { "BAZ" }
      output.should == "BAZ"
    end

    it "adds a digest of the template source to the cache key" do
      context.assigns[:cache_key] = "x"

      template.stub(:source) { "{{bar}}" }
      output.should == "BAR"

      template.stub(:source) { "FOO{{bar}}" }
      output.should == "FOOBAR"
    end

    it "expires the cache keys after #cache_duration" do
      context.assigns[:cache_key] = "x"
      context.assigns[:cache_duration] = 42

      output.should == "BAR"

      context.stub(:bar) { "FOO" }

      # Cached fragment has not yet expired.
      context.advance_clock(41)
      output.should == "BAR"

      # Now it has! Huzzah!
      context.advance_clock(1)
      output.should == "FOO"
    end
  end

  def output
    code = Curly::TemplateHandler.call(template)
    context.instance_eval(code)
  end
end
