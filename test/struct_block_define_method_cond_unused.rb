# A define_method under a run-time condition in a Struct.new or Data.define
# block is refused where it can run (struct_block_define_method_cond), but
# not inside a method nothing calls: that block never runs (#10033).
def unused
  Struct.new(:a) do
    if ENV["NOPE"]
      [:x].each { |n| define_method(n) { 1 } }
    end
  end
end

def unused_data
  Data.define(:a) do
    if ENV["NOPE"]
      [:x, :y].each { |n| define_method(n) { 1 } }
    end
  end
end

puts "ok"
