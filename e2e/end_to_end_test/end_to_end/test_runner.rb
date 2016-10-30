class TestEndToEndRunner < Minitest::Test
  def test_initialize
    runner = EndToEnd::Runner.new
    assert_equal [], runner.arguments
    assert_equal Hash.new, runner.options

    args = %w[--pry --load-app file1 file2]
    runner = EndToEnd::Runner.new(args)
    assert_equal args, runner.arguments
    assert_equal Hash.new, runner.options
  end

  def test_parse_with_no_arguments
    runner = EndToEnd::Runner.new
    assert_equal runner, runner.parse!
    assert_equal Hash.new, runner.options
    assert_equal EndToEnd.all_feature_files, runner.feature_files
  end

  def test_parse_with_arguments
    runner = EndToEnd::Runner.new(
        %w[
          --browser ios
          --config other_config.yml
          --env production
          --load-app
          --pry
          features/feature_1 features/feature_2
        ]
      )
    assert_equal runner, runner.parse!
    assert_equal({
        browser: 'ios',
        environment: 'production',
        config: 'other_config.yml',
        load_app: true,
        pry: true
      }, runner.options)
    assert_equal 2, runner.feature_files.size
    assert_match %r{/end_to_end/features/feature_1}, runner.feature_files[0]
    assert_match %r{/end_to_end/features/feature_2}, runner.feature_files[1]
  end

  def test_set_instance
    runner = EndToEnd::Runner.new(%w[--config other_config.yml features/feature])
    original_instance = EndToEnd.instance
    runner.parse!
    runner.set_end_to_end_instance
    refute_equal original_instance, EndToEnd.instance
    assert_equal runner.options[:config], EndToEnd.instance.options[:config]
  end
end
