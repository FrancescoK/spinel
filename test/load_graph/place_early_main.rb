# What a file defines is not there before the method that requires it runs:
# the reads before it see nil, nil and a NameError, the reads after see them.
def setup = require_relative("place_early_lib")
p $g
p @iv
begin
  p LIMIT
rescue NameError
  p :name_error
end
setup if ARGV.empty?
p $g
p @iv
p(defined?(LIMIT) ? LIMIT : :none)
