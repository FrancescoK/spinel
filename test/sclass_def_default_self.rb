# A method defined in `class << self` evaluates its parameter defaults in the
# method, whose self is the class, also when called from another class
# (a class method `open(path = default_path, registry_path:
# default_registry_path)` called from a Thor command).
class Index
  class << self
    def default_path = "data/x.db"
    def default_reg = "reg.yml"
    def open(path = default_path, reg: default_reg) = new(path, reg)
  end
  def self.open2(path = default_path) = new(path, "r2")
  def initialize(path, reg) = (@path = path; @reg = reg)
  def to_s = "#{@path} #{@reg}"
end
class Cli
  def run = [Index.open.to_s, Index.open("given").to_s, Index.open2.to_s]
end
p Cli.new.run
