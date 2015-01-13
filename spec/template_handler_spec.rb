describe Curly::TemplateHandler do
  let :presenter_class do
    Class.new do
      def initialize(context, options = {})
        @context = context
        @cache_key = options.fetch(:cache_key, nil)
        @cache_duration = options.fetch(:cache_duration, nil)
        @cache_options = options.fetch(:cache_options, {})
      end

      def setup!
        @context.content_for(:foo, "bar")
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

      def cache_options
        @cache_options
      end

      def self.component_available?(method)
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

      def reset!
        @output_buffer = ActiveSupport::SafeBuffer.new
      end

      def advance_clock(duration)
        @clock += duration
      end

      def content_for(key, value = nil)
        @contents ||= {}
        @contents[key] = value if value.present?
        @contents[key]
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

  it "should fail if there's no matching presenter class" do
    template.stub(:virtual_path) { "missing" }
    template.stub(:source) { " FOO " }
    expect { output }.to raise_exception(Curly::PresenterNotFound)
  end

  it "allows calling public methods on the presenter" do
    template.stub(:source) { "{{foo}}" }
    output.should == "FOO"
  end

  it "marks its output as HTML safe" do
    template.stub(:source) { "{{foo}}" }
    output.should be_html_safe
  end

  it "calls the #setup! method before rendering the view" do
    template.stub(:source) { "{{foo}}" }
    output
    context.content_for(:foo).should == "bar"
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

    it "adds the presenter class' cache key to the instance's cache key" do
      # Make sure caching is enabled
      context.assigns[:cache_key] = "x"

      presenter_class.stub(:cache_key) { "foo" }

      output.should == "BAR"

      presenter_class.stub(:cache_key) { "bar" }

      context.stub(:bar) { "FOOBAR" }
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

    it "passes #cache_options to the cache backend" do
      context.assigns[:cache_key] = "x"
      context.assigns[:cache_options] = { expires_in: 42 }

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
    context.reset!
    context.instance_eval(code)
  end
end
