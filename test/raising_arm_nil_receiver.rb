# A call no class defines, on a receiver that may also be nil (an optional
# parameter), raises NoMethodError behind the nil test (#7578). As an arm of
# a value-position if beside a String arm, or inside a chain whose other
# operands are bool, it builds as the call on a never-nil receiver does
# (#7544) and raises the message for what the receiver holds.
class Box
  def show(email, name: "")
    email + "/" + name
  end

  def chain(item = nil)
    x = if item.empty?
      ""
    else
      item.owner && item.owner.email
    end
    x
  end

  def nested(item = nil)
    show(if item.empty?
      ""
    else
      item.owner && item.owner.email && (item.owner && item.owner.email).downcase
    end, name: "n")
  end

  def pick(item = nil)
    item.lead && item.lead.active? && item.lead || item.fallback
  end
end

b = Box.new
begin; b.chain; rescue NoMethodError => e; puts e.message; end
p b.chain({})
p b.nested({})
h = { "a" => 1 }
begin; b.chain(h);  rescue NoMethodError => e; puts e.message; end
begin; b.nested(h); rescue NoMethodError => e; puts e.message; end
begin; b.pick(h);   rescue NoMethodError => e; puts e.message; end
begin; b.pick;      rescue NoMethodError => e; puts e.message; end
puts "done"
