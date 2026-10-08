# Forwarding self takes the callee's receiver or parameter ABI, transitively.
# A recursive cycle needs a handle only when one of its methods needs identity.
def forwarded_bytes(s) = s.bytesize
def forwarded_same(s, other) = s.equal?(other)
def forwarded_same_argument(s, other) = other.equal?(s)
def forwarded_append(s)
  s << "!"
  s.bytesize
end

class String
  def self_bytes_implicit = self_bytes_explicit
  def self_bytes_explicit = self.self_bytes_argument
  def self_bytes_argument = forwarded_bytes(self)
  def self_bytes_cycle(n)
    n == 0 ? bytesize : self_bytes_back(n - 1)
  end
  def self_bytes_back(n) = self_bytes_cycle(n)

  def self_handle_implicit(suffix) = self_handle_explicit(suffix)
  def self_handle_explicit(suffix) = self.self_handle_append(suffix)
  def self_handle_append(suffix)
    self << suffix
    bytesize
  end
  def self_handle_argument = forwarded_append(self)
  def self_handle_identity(other) = forwarded_same(self, other)
  def self_handle_identity_arg(other) = forwarded_same_argument(self, other)
  def self_handle_cycle(n)
    if n == 0
      self << "?"
      bytesize
    else
      self_handle_back(n - 1)
    end
  end
  def self_handle_back(n) = self_handle_cycle(n)
end

s = +"ab"
aliases = [s, 1]
s << "c"
p s.self_bytes_implicit
p aliases.first.self_bytes_explicit
p s.self_bytes_argument
p s.self_bytes_cycle(2)
p s.self_handle_implicit("d")
p s.self_handle_argument
p s.self_handle_identity(s)
p s.self_handle_identity_arg(s)
p s.self_handle_back(2)
p [s, aliases.first, s.equal?(aliases.first)]
p "lit".self_bytes_implicit
