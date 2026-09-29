# RbConfig::CONFIG, as far as a compiled program can have it: the build
# configuration library code branches on (host_os, host_cpu, the shared
# library suffixes), describing the machine the program was compiled for,
# derived from RUBY_PLATFORM. The parser splices this file when the program
# names `RbConfig` and defines none of its own.
module RbConfig
  __plat = RUBY_PLATFORM
  __darwin = __plat.include?("darwin")
  __cpu = __plat.split("-").first
  __cpu = "arm64" if __darwin && __cpu == "aarch64"
  __os = __darwin ? "darwin" : (__plat.include?("linux") ? "linux" : __plat.split("-").last)
  CONFIG = {
    "host_os" => __os, "target_os" => __os, "build_os" => __os,
    "host_cpu" => __cpu, "target_cpu" => __cpu, "build_cpu" => __cpu,
    "arch" => "#{__cpu}-#{__os}", "ruby_version" => RUBY_VERSION,
    "MAJOR" => RUBY_VERSION.split(".")[0], "MINOR" => RUBY_VERSION.split(".")[1],
    "EXEEXT" => "", "DLEXT" => (__darwin ? "bundle" : "so"),
    "SOEXT" => (__darwin ? "dylib" : "so"), "LIBEXT" => "a",
    "host" => __plat, "target" => __plat, "ruby_install_name" => "ruby"
  }

  def self.ruby = "ruby"
end
