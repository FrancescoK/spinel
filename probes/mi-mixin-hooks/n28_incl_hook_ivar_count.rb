# included: the hook keeps state in the module's own ivar across includes
module M
  @count = 0
  def self.included(b)
    @count += 1
    puts "inc #{b} #{@count}"
  end
  def self.count = @count
end
class A; include M; end
class B; include M; end
p M.count
