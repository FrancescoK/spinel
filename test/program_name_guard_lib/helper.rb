module Helper
  def self.guards
    [__FILE__ == $0, $0 == __FILE__, __FILE__ == $PROGRAM_NAME,
     File.expand_path(__FILE__) == File.expand_path($0)]
  end
end

if __FILE__ == $0
  puts "helper driver (must not run when required)"
end
