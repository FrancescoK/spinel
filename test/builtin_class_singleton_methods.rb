p IO.singleton_methods.include?(:read)
p IO.singleton_methods(false).include?(:new)
p File.singleton_methods.include?(:exist?)
p File.singleton_methods.include?(:read)
p File.singleton_methods(false).include?(:read)
p File.singleton_methods(false).include?(:new)
p String.singleton_methods.include?(:new)
p Integer.singleton_methods(false).include?(:sqrt)
p Array.singleton_methods.include?(:new)
p Hash.singleton_methods.include?(:new)
p Dir.singleton_methods.include?(:glob)
p Math.singleton_methods.include?(:sqrt)
p IO.singleton_methods.all? { |m| m.is_a?(Symbol) }

class String
  def self.shout = "hi"
end
p String.singleton_methods.include?(:shout), String.singleton_methods(false).include?(:new)
p Array.singleton_methods(false).include?(:try_convert)
p Integer.singleton_methods(false).include?(:try_convert)
p Hash.singleton_methods(false).include?(:try_convert)
p String.singleton_methods(false).include?(:try_convert)
p IO.singleton_methods(false).include?(:try_convert)
p Regexp.singleton_methods(false).include?(:try_convert)
p File.singleton_methods(false).include?(:foreach)
p IO.singleton_methods(false).include?(:foreach)
p File.singleton_methods(true).include?(:foreach)
