require_relative "../lib/commandline"
require_relative "../lib/RkGpxLogger"
require "test/unit"
require "fileutils"

# Test command line arguments behaviour
class TestCommandLine < Test::Unit::TestCase
  def setup
    @log = RkGpxLogger.new(STDOUT)
  end

  # These arguments should result in exit with 1 exit status
  @@test_exit=[
      "--help",
      "-help",
      "-h kk",
      "-H kk",
      "",
      "kk --help",
      "kk --HELP",
      "kk --Help",
      "kk -o kk -i",
      "kk -i -o kk",
      "kk -i -i",
      "kk -o"
    ]

  # These arguments should result in exit with 2 exit status (version)
  @@test_version=[
    "-V",
    "--version"
  ]

  def test_help_exit_raises
    @@test_exit.each { |a|
      assert_raise(SystemExit, "SystemExit expected for \"#{a}\"") {
        Commandline.new(a.split(' '), @log).parse
      }
    }
  end

  def test_version_exit_raises
    @@test_version.each { |a|
      assert_raise(SystemExit, "SystemExit expected for \"#{a}\"") {
        Commandline.new(a.split(' '), @log).parse
      }
    }
  end

  def test_help_exit_status
    @@test_exit.each { |a|
      begin
        Commandline.new([a], @log).parse
      rescue SystemExit => e
        assert e.status == 1
      end
    }
  end

  def test_version_exit_status
    @@test_version.each { |a|
      begin
        Commandline.new([a], @log).parse
      rescue SystemExit => e
        assert e.status == 2
      end
    }
  end

  def test_files_input
    arr=["kk", "aa", "bb", "cc"]

    # Simulate existing files
    arr.each { |f| FileUtils.touch(f) }

    test_input = {
      "kk aa bb cc" => 'Arguments: kk aa bb cc; files.count: 4; output_dir: ; edit_in_place: false; ',
      "kk aa bb" => 'Arguments: kk aa bb; files.count: 3; output_dir: ; edit_in_place: false; ',
      "-i kk aa bb" => 'Arguments: -i kk aa bb; files.count: 3; output_dir: ; edit_in_place: true; ',
      "-o kk aa bb" => 'Arguments: -o kk aa bb; files.count: 2; output_dir: kk; edit_in_place: false; ',
      "-he kk" => 'Arguments: -he kk; files.count: 1; output_dir: ; edit_in_place: false; ',
      "-ehelp kk" => 'Arguments: -ehelp kk; files.count: 1; output_dir: ; edit_in_place: false; ',
    }

    test_input.each { |key, value|
      cmd=Commandline.new(key.split(' '), @log)
      cmd.parse
      assert_equal(cmd.to_s, value)
    }

    # Delete dummy existing files
    arr.each {|f| File.delete(f) }

  end
end
