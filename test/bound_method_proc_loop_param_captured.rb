# A method turned into a proc (`&obj.method(:m)`) runs through a trampoline
# that declares the method's locals itself. A loop parameter an inner proc
# captures lives in a cell beside its plain slot, and the plain slot was
# declared twice there, so the C did not compile.
class Watcher
  def initialize = @info = { "a" => [1, 7], "b" => nil }

  def run
    out = []
    @info.each { |key, list|
      next unless list
      list.each { |v| pr = proc { out << [key, v] }; pr.call }
    }
    out
  end
end

w = Watcher.new
p w.run
t = Thread.start(&w.method(:run))
p t.value
p w.method(:run).to_proc.call
