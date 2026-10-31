puts "loading lib"
p defined?(LoadingConst)
LoadingConst = 7 unless defined?(LoadingConst)
p defined?(LoadingConst)
p defined?(LoadingClass)
class LoadingClass
  def self.v = 3
end
p defined?(LoadingClass)
