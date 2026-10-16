# is_a? / kind_of? / instance_of? on an exception, with the class held in a
# variable, a parameter, an ivar or a Hash key rather than written literally.
class Bad < StandardError; end
class Invalid < Bad; end
module Tag; end
module Admin
  class Oops < Invalid
    include Tag
  end
end

def match?(e, klass) = e.is_a?(klass)
def exact?(e, klass) = e.instance_of?(klass)

[Invalid, Admin::Oops].each do |raised|
  begin
    raise raised, "x"
  rescue => e
    [Bad, Invalid, Admin::Oops, StandardError, Exception, ArgumentError, Object, Kernel, Tag, Comparable].each do |k|
      p [k, match?(e, k), e.kind_of?(k), exact?(e, k)]
    end
  end
end

begin
  Integer("q")
rescue => e
  k = StandardError
  p match?(e, k), match?(e, Bad), exact?(e, ArgumentError)
end

# the first handler whose class matches, as rescue_from looks one up
handlers = { Bad => "bad", StandardError => "std" }
begin
  raise Invalid, "y"
rescue => e
  p handlers.find { |klass, _| e.is_a?(klass) }&.last
end

# a value that is no Class or Module is a TypeError
begin
  raise Invalid, "z"
rescue => e
  [Bad, "Bad"].each do |k|
    begin
      p e.is_a?(k)
    rescue TypeError => te
      p te.message
    end
  end
end

class Holder
  def initialize(k) = @k = k
  def check(e) = e.is_a?(@k)
end
begin
  raise Invalid
rescue => e
  p Holder.new(Bad).check(e), Holder.new(ArgumentError).check(e)
end

# a Class-typed local: exact test, namespaced, a builtin known by name only
begin
  raise Admin::Oops, "n"
rescue => e
  k = Invalid
  p e.instance_of?(k), e.is_a?(k)
  k = Admin::Oops
  p e.instance_of?(k), e.is_a?(k)
end
begin
  File.read("/nonexistent/spinel-test")
rescue => e
  k = Errno::ENOENT
  p e.is_a?(k), e.instance_of?(k)
  k = SystemCallError
  p e.is_a?(k), e.instance_of?(k)
end

# a nil class is a TypeError too
def opt(e, k = nil) = e.is_a?(k)
begin
  raise Invalid, "w"
rescue => e
  begin
    p opt(e)
  rescue TypeError => te
    p te.message
  end
  p opt(e, Bad)
end
