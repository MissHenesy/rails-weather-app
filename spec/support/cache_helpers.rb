# Found an excellent approach to test cacheing at:
# https://dev.to/epigene/simple-testing-of-rails-cache-with-rspec-j5
RSpec.shared_context('with cache', :with_cache) do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  def is_cached?(key)
    Utilities::AppUtils.is_cached?(key)
  end

  def cache_data(key, duration, units, &block)
    Utilities::AppUtils.cache_data(key, duration, units, &block)
  end
end
