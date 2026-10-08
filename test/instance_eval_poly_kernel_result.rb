# An unconstrained receiver does not box the result of a Kernel global.
# The self-call rewrite leaves these calls receiverless, including p when
# its Class or Array result becomes the value of the eval block.
def eval_kernel_results(obj)
  p obj.instance_eval { p self.class }
  p obj.instance_exec([1, 2]) { |v| p v }
  p obj.instance_exec(3, 4) { |a, b| p(a, b) }
  p obj.instance_exec({key: 5}) { |v| p v }
  p obj.instance_eval { p }
  p obj.instance_eval { puts "inside" }
  p obj.instance_eval { sprintf("value:%d", 6) }
end

eval_kernel_results(Object.new)
eval_kernel_results(1)
