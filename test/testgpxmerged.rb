require_relative "../lib/GpxMerged"
require_relative "../lib/RkGpxLogger"
require "test/unit"

# Test command line arguments behaviour
class TestGpxMerged < Test::Unit::TestCase

  def setup
    @log = RkGpxLogger.new(STDOUT)
  end

  def teardown
    # nothing
  end

  def test_invalid_arg_raises
    assert_raise(ArgumentError, "Either option :output_dir or option :in_place must be provided") {
      GpxMerged.new(["1.gpx", "2.gpx"], @log)
    }
  end

  def test_in_place
    gpx_merged = GpxMerged.new(["1.gpx", "2.gpx"], @log, :in_place => true)
    assert_equal(gpx_merged.in_place, true);
  end

  def test_out_dir
    gpx_merged = GpxMerged.new(["1.gpx", "2.gpx"], @log, :output_dir => "kk")
    assert_equal(gpx_merged.dir, "kk")
  end
end
