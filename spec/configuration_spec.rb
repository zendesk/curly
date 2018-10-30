describe Curly::Configuration do
  after do
    Curly.reset
  end

  describe "#cache_store" do
    it "defaults to nil" do
      cache_store = Curly::Configuration.new.cache_store

      expect(cache_store).to be_nil
    end
  end

  describe ".configure" do
    before do
      Curly.configure do |config|
        config.cache_store = 'foobar'
      end
    end

    it "returns correct value for cache_store" do
      presenters_namespace = Curly.configuration.cache_store

      expect(presenters_namespace).to eq('foobar')
    end
  end

  describe ".reset" do
    it "resets the configuration to default value" do
      Curly.configure do |config|
        config.cache_store = 'foobarbaz'
      end

      Curly.reset

      cache_store = Curly::Configuration.new.cache_store

      expect(cache_store).to be_nil
    end
  end
end
