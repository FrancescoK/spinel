# strict-require: `require "io/console"` enables the IO console surface
# (IO#winsize). Without the require, winsize is unresolved under
# SPINEL_STRICT_REQUIRE (matching CRuby's NoMethodError); with it, the
# C-native sp_File_winsize is provided. The harness redirects stdout, so
# winsize reports [0, 0]. Locks the enable path (works gate on or off).
require "io/console"
p STDOUT.winsize
