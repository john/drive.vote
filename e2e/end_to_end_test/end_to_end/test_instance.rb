class TestEndToEndInstance < Minitest::Test
  if ENV['TEST_REQUIRES']
    def test_initialize_loading_pry_and_app
      EndToEnd::Instance.new(pry: true, load_app: true)
      assert Rails
      assert Pry
    end

    def test_load_app
      end_to_end = EndToEnd::Instance.new
      loaded = end_to_end.load_app
      # May already be loaded from a prior test, so just check for boolean response
      assert_equal !!loaded, loaded
    end

    def test_load_pry
      end_to_end = EndToEnd::Instance.new
      loaded = end_to_end.load_pry
      # May already be loaded from a prior test, so just check for boolean response
      assert_equal !!loaded, loaded
    end
  end

  def test_config
    config = EndToEnd::Instance.new.config
  end

  def test_config_path_default
    path = EndToEnd::Instance.new.config_path
    assert path.is_a?(Pathname)
    assert_match %r{/.*/end_to_end/config.yml}, path.to_s
  end

  def test_config_path_with_relative_path
    path = EndToEnd::Instance.new(config: 'relative/path/to/config.yml').config_path
    assert path.is_a?(Pathname)
    assert_match %r{/.*/end_to_end/relative/path/to/config.yml}, path.to_s
  end

  def test_config_path_with_full_path
    path = EndToEnd::Instance.new(config: '/full/path/to/config.yml').config_path
    assert path.is_a?(Pathname)
    assert_equal '/full/path/to/config.yml', path.to_s
  end

  def test_app_loaded
    end_to_end = EndToEnd::Instance.new
    refute end_to_end.app_loaded?
    end_to_end.instance_variable_set(:@options, { load_app: true })
    assert end_to_end.app_loaded?
  end

  def test_environment
    end_to_end = EndToEnd::Instance.new
    assert_equal 'development', end_to_end.environment
    end_to_end.instance_variable_set(:@options, { environment: 'production' })
    assert_equal 'production', end_to_end.environment
  end

  def test_pull_request
    end_to_end = EndToEnd::Instance.new
    assert_equal nil, end_to_end.pull_request
    end_to_end.instance_variable_set(:@options, { environment: 'staging', pr: '121' })
    assert_equal '121', end_to_end.pull_request
  end
end
