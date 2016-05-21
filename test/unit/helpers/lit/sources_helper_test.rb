require 'test_helper'

class SourcesHelperTest < ActionView::TestCase
  include Lit::SourcesHelper
  
  def setup
    @source = Lit::Source.new
  end

  test 'returns "loaded" when source sync is complete' do
    @source.sync_complete = true
    assert_equal source_loading_class(@source), 'loaded'
  end

  test 'returns "loading" when source sync is not complete' do
    @source.sync_complete = false
    assert_equal source_loading_class(@source), 'loading'
  end
end
