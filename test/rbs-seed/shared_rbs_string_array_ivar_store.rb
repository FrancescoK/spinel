# An `Array[String]?` instance variable an --rbs signature pins, whose
# Strings the share rule shares, takes the boxed Array of shared handles
# (share_box_ivar_family), and a String Array written into it is wrapped
# element by element. The seed check took that store for a reinterpretation
# ("@to is declared Array[untyped] but this assigns Array[String]") and
# refused the program: Roundhouse's ActionMailer::Message stopped there.
# The receivers the analysis cannot see (`send` to a
# define_singleton_method) and a program class's own `map` and `fetch`
# are what lead the share rule to box the slot.
class ShrbsiRows
  def initialize(rows)
    @rows = rows
  end

  def map
    out = []
    i = 0
    while i < @rows.length
      out.push(yield @rows[i])
      i += 1
    end
    out
  end
end

class ShrbsiScan
  define_singleton_method(:out_of) { +"" }
  define_singleton_method(:node_of) { { "__name" => 2 } }
  out = send(:out_of)
  node = send(:node_of)
  out << 1 if node.fetch("__name", "") == 2
  p out
end

class ShrbsiStore
  def fetch(name, default = nil)
    value = name
    if value.instance_of?(Array)
      value = value.length
    end
    if value.instance_of?(Hash)
      value.each do |key, item|
        p [key, item]
      end
    end
    value
  end
end

class ShrbsiMessage
  define_singleton_method(:list_of) { |value| value.is_a?(Array) ? value : [value] }

  def initialize(opts)
    @to = ShrbsiMessage.addresses(opts[:to])
  end

  def to
    @to
  end

  def self.addresses(value)
    send(:list_of, value).map do |item|
      item.to_s
    end
  end
end

p ShrbsiRows.new([1, 2]).map { |x| x + 1 }
p ShrbsiMessage.new({ to: "a@b" }).to
