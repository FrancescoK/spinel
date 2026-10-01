p Kernel.const_get(:RUBY_VERSION) == RUBY_VERSION
p Comparable.const_get(:RUBY_ENGINE) == RUBY_ENGINE
p Math.const_get("RUBY_PLATFORM") == RUBY_PLATFORM
p String.const_get(:Integer)
p Kernel.const_get(:STDOUT) == STDOUT
p((BasicObject.const_get(:RUBY_VERSION) rescue $!.class))
