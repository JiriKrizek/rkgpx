# encoding: utf-8
require_relative '../lib/GeoCoder.rb'

require "test/unit"

# Test command line arguments behaviour
class TestGeoCoder < Test::Unit::TestCase

  def setup
    @log = RkGpxLogger.new("testlog.txt")
  end

  def teardown
    # nothing
  end

  def test_invalid_arg_raises
    gc=GeoCoder.new(@log)
    [1.1, 32,"loremipsum",nil].each do |arg|
      assert_raise(ArgumentError, 'Argument of "address" method must be GeoPoint') {
        gc.address(arg)
      }
    end
  end

  def test_valid_response
    gc=GeoCoder.new(@log)

    assert_equal(nil, gc.address(GeoPoint.new(30.529145,-107.176094)))

    assert_equal("Bedford Ave, New York", gc.address(GeoPoint.new(40.714224,-73.961452)))

    assert_equal("K zahradě, Kačice", gc.address(GeoPoint.new(50.160488000, 13.985861000)))
  end
end
