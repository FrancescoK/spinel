# Reading self's bytes does not require a handle-taking method.
class String
  def receiver_bytes_only = bytesize
end
s = +"ab"
values = [s, 1]
s << "c"
p s.receiver_bytes_only
p values.first.receiver_bytes_only
