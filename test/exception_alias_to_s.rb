# An exception class whose to_s is an alias of its message answers that
# method wherever the exception is read as text: to_s, message,
# interpolation and $!, in the class and in a subclass. The other
# direction, and alias_method, answer the same.
class AliasToS < StandardError
  def message; "custom"; end
  alias to_s message
end
class AliasToSChild < AliasToS; end
class AliasMessage < StandardError
  def to_s; "from to_s"; end
  alias message to_s
end
class AliasMethodToS < StandardError
  def detail; "detail #{self.class}"; end
  alias_method :to_s, :detail
end
begin; raise AliasToS; rescue => e; puts e.to_s; puts e.message; puts "[#{e}]"; end
begin; raise AliasToS, "given"; rescue => e; puts "[#{e}]"; end
begin; raise AliasToSChild; rescue; puts "[#{$!}]"; end
begin; raise AliasMessage; rescue => e; puts e.message; puts "[#{e}]"; end
begin; raise AliasMethodToS; rescue => e; puts e.to_s; puts e.message; puts "[#{e}]"; end
