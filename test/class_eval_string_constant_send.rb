# A class_eval string that calls through an interpolated constant holding a
# method's name (racc's parser.rb: `#{Racc_Main_Parsing_Routine}(...)`) is
# the send of what the constant holds.
class Runner
  Main_Routine = :run_c
  Yy_Routine = :yy_c

  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def go(arg)
      #{Main_Routine}(arg, false)
    end
  RUBY

  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def yy(recv, mid)
      #{Yy_Routine}(recv, mid, setup(), false)
    end
    def tag
      #{Main_Routine}()
    end
  RUBY

  def setup = :s

  private

  def run_c(arg = :none, debug = true)
    [:c, arg, debug]
  end

  def yy_c(recv, mid, arg, debug)
    [recv, mid, arg, debug]
  end
end

r = Runner.new
p r.go(42)
p r.yy("rx", :tok)
p r.tag
