# strict-require: `require "io/console"` enables the IO console surface
# (IO#winsize). Without the require, winsize is unresolved under
# SPINEL_STRICT_REQUIRE (matching CRuby's NoMethodError); with it, the
# C-native sp_File_winsize is provided. The harness redirects stdout, so
# winsize raises Errno::ENOTTY, as CRuby's does. Locks the enable path
# (works with strict require on or off).
require "io/console"
begin
  p STDOUT.winsize
rescue Errno::ENOTTY => e
  p e.class
end
