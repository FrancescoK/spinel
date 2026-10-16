# A Struct subclass's `new` as a superclass makes a Struct below it, as
# faraday's `class RetryOptions < Options.new(:max, :interval)` does (#9292)
class Options < Struct
  def self.from(value) = value ? new(*value) : new
  def to_pairs = members.map { |m| [m, self[m]] }
  def merge(other) = self.class.new(*members.map { |m| other[m] || self[m] })
  def describe = "#{self.class.name}(#{to_h})"
end

class Middle < Options
  def middle? = true
end

class RetryOptions < Options.new(:max, :interval)
  def self.default = new(2, 0.5)
end

class RequestOptions < Options.new(:timeout, :open_timeout)
  def timeout = self[:timeout] || 60
end

class SSLOptions < Middle.new(:verify, :ca_file) do
  def verify? = verify != false
end
  def describe = "ssl " + super
end

class KwOptions < Options.new(:a, :b, keyword_init: true)
end

class SubRequest < RequestOptions
  def sub = :sub
end

ProxyOptions = Options.new(:uri, :user)

o = RetryOptions.default
p o.max, o.interval, o.to_pairs, RetryOptions.from([3, 1]).max
p o.is_a?(Options), o.is_a?(Struct), Options === o, o.class, o

r = RequestOptions.new(nil, 5)
s = SSLOptions.from([false, "ca.pem"])
k = KwOptions.new(a: 1, b: 2)
q = SubRequest.new(3, 4)
x = ProxyOptions.new("http://proxy", "me")
p r.timeout, r.to_pairs, r.merge(RequestOptions.new(10, nil)).to_pairs
p s.verify?, s.middle?, s.describe, s.to_pairs
p k.to_pairs, k.describe
p q.sub, q.to_pairs, q.is_a?(RequestOptions), q.is_a?(Options)
p x.to_pairs, x.is_a?(Options), ProxyOptions.from(["u", nil]).to_pairs
[o, r, s, k, q, x].each { |v| p [v.class.name, v.to_pairs.size, v.is_a?(Options)] }
p SSLOptions.from(nil).to_pairs, RequestOptions.members
