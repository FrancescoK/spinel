# A program that finds a class by name keeps every class: const_get can
# answer any of them (#10592).
# present: sp_Square_area sp_Square_initialize
class Square
  def initialize(w) = @w = w
  def area = @w * @w
end
k = Object.const_get(ARGV.empty? ? "Square" : ARGV[0])
p k.new(3).area
