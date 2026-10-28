# An alias made in a reopening between two definitions of a method names
# the earlier one, and a call between the two reaches that body, also when
# nothing calls the alias.
class B; def get = 1; end
class B; alias_method :old, :get; end
p B.new.get
class B; def get = 2; end
p B.new.get
