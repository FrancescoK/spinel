# `class Inner < self` in a class body: self is the class being defined, so
# Inner is its subclass (activerecord's Promise::Complete < Promise).
module Store
  class Promise
    def initialize(v) = @v = v
    def value = @v
    def status = :pending

    class Complete < self
      def status = :complete
    end

    class Failed < self
      def status = :failed
      def value = raise("failed: #{super}")
    end
  end
end

c = Store::Promise::Complete.new(1)
p c.value, c.status, c.is_a?(Store::Promise), Store::Promise::Complete.superclass
f = Store::Promise::Failed.new(2)
begin
  f.value
rescue => e
  p e.message
end
p Store::Promise.new(3).status
