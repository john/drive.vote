class TestEndToEnd < Minitest::Test
  def test_instance
    assert EndToEnd.instance.is_a?(EndToEnd::Instance)
  end

  # Note: This test does nothing if the features folder is empty
  def test_all_feature_files
    EndToEnd.all_feature_files.map { |path|
      assert_match %r{/end_to_end/features/.*\.rb}, path
    }
  end

  def test_root
    assert EndToEnd.root.is_a?(Pathname)
    assert EndToEnd.root.to_s =~ %r{/end_to_end}
  end

  def test_delegates_method_missing_to_instance
    refute EndToEnd.method_defined?(:options)
    assert_equal EndToEnd.instance.options.hash, EndToEnd.options.hash
  end
end
