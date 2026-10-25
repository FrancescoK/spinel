# An exception interpolates as its to_s, as CRuby does: a class that
# defines to_s gives what it returns, with or without a message, from
# the rescue variable and from $!; one that defines only message keeps
# the default to_s.
class E < StandardError
  def to_s; "custom"; end
end
class G < StandardError
  def message; "msg"; end
end
begin; raise E; rescue => e; puts "[#{e}]"; end
begin; raise E, "given"; rescue => e; puts "[#{e}]"; end
begin; raise E; rescue; puts "[#{$!}]"; end
begin; raise G; rescue => g; puts "[#{g}]"; end
begin; raise StandardError, "plain"; rescue => s; puts "[#{s}]"; end
