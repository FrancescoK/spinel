class File
  class << self
    private
    def readable?(x) = "priv"
  end
end
begin
  p File.readable?("/")
rescue NoMethodError => e
  puts "NoMethodError"
end
