# fiber-annotation 0.2.0 as the gem ships it (comments removed): its
# initialize, prepended onto Fiber, runs on the new fiber and supers its
# keywords into Fiber.new; the method_defined? guard folds (#9384)
class Fiber
  module Annotation
    def initialize(annotation: nil, **options, &block)
      @annotation = annotation
      super(**options, &block)
    end

    attr_accessor :annotation

    def annotate(annotation)
      if block_given?
        raise "Cannot annotation a different fiber!" unless Fiber.current == self
        begin
          current_annotation = @annotation
          @annotation = annotation
          return yield
        ensure
          @annotation = current_annotation
        end
      else
        @annotation = annotation
      end
    end
  end
end

unless Fiber.method_defined?(:annotation)
  Fiber.prepend(Fiber::Annotation)

  def Fiber.annotate(...)
    Fiber.current.annotate(...)
  end
end

f = Fiber.new(annotation: "worker") { Fiber.current.annotation }
p f.annotation
p f.resume
p Fiber.new { 1 }.annotation
b = Fiber.new(annotation: :b, blocking: true) { Fiber.current.blocking? }
p [b.annotation, b.blocking?, b.resume]
s = Fiber.new(storage: {k: 1}) { Fiber[:k] }
p s.resume
g = Fiber.new do
  Fiber.annotate("inner") { Fiber.current.annotation }
end
p g.resume
begin
  Fiber.new(annotation: 1, colour: 2) { }
rescue ArgumentError => e
  p e.message
end
