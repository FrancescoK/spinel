require_relative "a04_req_prepend_lib/a04_lib"
class K
  def hi = "K"
end
p K.new.hi
require_relative "a04_req_prepend_lib/a04_lib2"
p K.new.hi
