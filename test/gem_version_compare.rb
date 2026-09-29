# Gem::Version compares like RubyGems' (numeric segments as numbers, a
# prerelease before its release), qualified from inside a module that has its
# own Version (rbnacl's Sodium::Version.supported_version?).
module Lib
  module Version
    STRING = "1.0.18"
    def self.supported_version?(version)
      Gem::Version.new(STRING) >= Gem::Version.new(version)
    end
  end
end
p Lib::Version.supported_version?("1.0.9")
p Lib::Version.supported_version?("1.1")
p Gem::Version.new("1.2.0.rc1") < Gem::Version.new("1.2.0")
p Gem::Version.new("2.10") > Gem::Version.new("2.9")
p Gem::Version.new("1.0") == Gem::Version.new("1.0")
# letter and digit runs are segments of their own: rc10 is after rc9
p Gem::Version.new("1.0.rc10") > Gem::Version.new("1.0.rc9")
p Gem::Version.new("1.0.0.pre2") < Gem::Version.new("1.0.0.pre10")
p Gem::Version.new("2.0.0a") < Gem::Version.new("2.0.0")
