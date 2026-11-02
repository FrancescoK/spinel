module M
  def a = :a
end
require_relative "a10_extend_self_req_lib/a10_lib"
p M.a
p M.b
