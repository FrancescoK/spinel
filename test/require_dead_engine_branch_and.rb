# A require in a branch that `and`, `or` or `Object.const_defined?(:RUBY_ENGINE)`
# settles as dead is not loaded (racc's parser.rb: `if
# Object.const_defined?(:RUBY_ENGINE) and RUBY_ENGINE == 'jruby'`).
loaded = []
begin
  if Object.const_defined?(:RUBY_ENGINE) and RUBY_ENGINE == 'jruby'
    require 'jruby'
    loaded << :jruby
  else
    loaded << :native
  end
  if defined?(RUBY_ENGINE) && RUBY_ENGINE != 'spinel' && RUBY_ENGINE != 'ruby'
    require 'no_such_engine_lib'
  end
  loaded << (RUBY_ENGINE == 'jruby' or RUBY_ENGINE == 'truffleruby' ? :other : :here)
rescue LoadError
  loaded << :load_error
end
p loaded
