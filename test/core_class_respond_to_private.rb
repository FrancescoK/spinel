# A core class or module object answers Class's and Module's private methods
# to respond_to?(name, true), as a user one does
p String.respond_to?(:private), String.respond_to?(:private, true)
p String.respond_to?(:inherited, true), String.respond_to?(:method_added, true)
p String.respond_to?(:module_function, true), String.respond_to?(:refine, true)
p Comparable.respond_to?(:module_function, true), Comparable.respond_to?(:included, true)
p Comparable.respond_to?(:inherited, true), Comparable.respond_to?(:append_features, true)
p Kernel.respond_to?(:extend_object, true), Integer.respond_to?(:remove_const, true)
