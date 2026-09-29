# A require inside a method body loads ahead of the top-level statement it
# sits in, not at the start of the program: the file's own top level runs
# after what the program does before that statement.
$log = [:main]
class User
  def go
    require_relative "require_in_method_order/lib"
    Lib.v
  end
end
p User.new.go
