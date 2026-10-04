# instance_exec(args, &g) with a proc that arrives through a parameter is
# run on the receiver only when every call site hands a proc literal there;
# one made elsewhere (`mk`) cannot be traced, and is refused at compile time
# rather than raising NoMethodError when the line runs.
class Ctx
end
def mk = ->(n) { n * 2 }
def run(g) = Ctx.new.instance_exec(3, &g)
p run(mk)
