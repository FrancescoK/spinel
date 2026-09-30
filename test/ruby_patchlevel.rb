p RUBY_PATCHLEVEL
p RUBY_PATCHLEVEL.class
p RUBY_PATCHLEVEL >= 0
p defined?(RUBY_PATCHLEVEL)
p Object::RUBY_PATCHLEVEL + 1
p Object.const_get(:RUBY_PATCHLEVEL).zero?
p Object.const_defined?(:RUBY_PATCHLEVEL)
