require "set"

class Claims
  @claims = Set.new
  @mutex = Mutex.new

  class << self
    def include?(claim)
      @mutex.synchronize { @claims.include?(claim) }
    end

    def holding(claim)
      @mutex.synchronize { @claims.add(claim) }
      yield
    ensure
      @mutex.synchronize { @claims.delete(claim) }
    end
  end
end

def resuming?(claim) = Claims.include?(claim)

p resuming?("a")
Claims.holding("a") { p resuming?("a") }
p !Claims.include?("a") && true

class UntypedPredicate
  #: (String?) -> untyped
  def self.include?(value) = value.nil?
end

def untyped_predicate?(value) = UntypedPredicate.include?(value)
p untyped_predicate?(nil)
p !UntypedPredicate.include?("a")

class InheritedPredicate < UntypedPredicate
end
p InheritedPredicate.include?(nil)

module Predicates
  class Words
    def self.include?(value) = value
  end
end
p Predicates::Words.include?("present")

module Marker
end
class Marked
  include Marker
end
p Marked.include?(Marker)
p Marked.include?(Enumerable)
