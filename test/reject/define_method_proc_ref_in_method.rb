# spinel: reject-subclass: Module#define_method with `&` of a block or Proc that is not a literal
# In a method body, with the Proc the method is given: the method was defined
# from the start with no body (and a `private` naming it refused the build as
# a method the class answers before the define_method runs).
class Layouts
  def self.layout(body)
    if body.is_a?(Proc)
      define_method :layout_from_proc, &body
      private :layout_from_proc
    end
    body
  end
  def show = layout_from_proc
end
Layouts.layout(proc { "called" })
p Layouts.new.show
