class B
  tap { |x| p x }
  p name
  p frozen?
  p is_a?(Class)
  p instance_methods(false)
  def m = 1
  p instance_methods(false)
end
