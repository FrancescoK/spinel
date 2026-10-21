# An exception subclass's own allocate class method still answers.
class Custom < StandardError
  def self.allocate
    $calls += 1
    :custom
  end
end
$calls = 0
p Custom.allocate
p [Custom, 0][0].allocate
p $calls
