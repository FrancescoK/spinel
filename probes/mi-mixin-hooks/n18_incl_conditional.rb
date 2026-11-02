# included: hook defined under a runtime condition that does not hold
module M
  unless ARGV.empty?
    def self.included(b) = puts("inc #{b}")
  end
end
class A; include M; end
puts "done"
