class K
  y = 0
  module_eval do
    y = 5
    z = 1
  end
  p y
  p defined?(z)
end
