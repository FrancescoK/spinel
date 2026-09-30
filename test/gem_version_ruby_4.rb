p Gem::VERSION.split(".")[0, 2]
p Gem::Version.new(Gem::VERSION) >= Gem::Version.new("4.0")
p Gem::Version.new(Gem::VERSION) < Gem::Version.new("4.1")
