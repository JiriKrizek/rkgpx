Runkeeper GPX Fix
=======================================================================

rkgpx is utility to repair GPX files generated by RunKeeper.

   * __DONE__ - Fixes file to be valid GPX (XML file)
   * __TODO__ - Fix trkpt timestamps to be able to merge more gpx files.
   * __TODO__ - Add ability to merge more gpx files, if trackpoints are continuous
   * __TODO__ - Add treshhold switch

### Usage

`ruby gpx.rb file.gpx [file2.gpx...] -i|-o DIR|--help [-t]`

   * gpx.rb - name of script
   * file.gpx file2.gpx - one or more file names to fix
   * `-i` - fix files "in place"
   * `-o DIR` - put output files to directory _DIR_
   * `--help`, `-h` - print usage
   * `-t` - treshhold for merge tolerance in meters (default 20 meters = 65 feet)
      * `-t 10` - treshhold 10 meters
      * `-t 10m` treshhold 10 meters
      * `-t 10ft` - treshhold 10feet = 3.05 meters
