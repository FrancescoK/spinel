# lib/win32/overlay: what a native Windows build answers differently, read
# after builtins/rbconfig.rb. RUBY_PLATFORM is x64-mingw-ucrt there; the OS
# CRuby's RbConfig names for it is mingw32, and programs end in .exe and
# shared libraries in .dll.
module RbConfig
  CONFIG["host_os"] = "mingw32"
  CONFIG["target_os"] = "mingw32"
  CONFIG["build_os"] = "mingw32"
  CONFIG["arch"] = "#{CONFIG["host_cpu"]}-mingw32"
  CONFIG["EXEEXT"] = ".exe"
  CONFIG["SOEXT"] = "dll"
end
