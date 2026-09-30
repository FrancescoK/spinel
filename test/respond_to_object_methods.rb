# Every object responds to Object's public instance methods, whether the
# receiver is typed, boxed, or the name is known only at run time.

class O; end

NAMES = %i[define_singleton_method instance_eval instance_exec singleton_method
           singleton_methods public_method public_methods private_methods
           protected_methods remove_instance_variable __id__ ! !~ <=>]

p O.new.respond_to?(:define_singleton_method)
p O.new.respond_to?(:instance_exec)
p O.new.respond_to?(:singleton_methods)
p O.new.respond_to?(:!)
p 1.respond_to?(:instance_eval)
p "s".respond_to?(:public_method)
p nil.respond_to?(:remove_instance_variable)

xs = [O.new, 1, "s", nil]
xs.each { |x| p NAMES.map { |n| x.respond_to?(n) }.all? }

name = "define_singleton_method"
p O.new.respond_to?(name)

p O.method_defined?(:define_singleton_method)
p O.public_method_defined?(:instance_exec)
