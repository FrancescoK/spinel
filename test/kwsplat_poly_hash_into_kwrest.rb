# A Hash read out of a poly-valued hash, forwarded with ** into a **kwrest
# parameter: its type is only known at run time, so its entries are merged
# into the keyword-rest when the call runs.

def take(path, **opts)
  "#{path} #{opts.size} #{opts.inspect}"
end

def take_kw(path, flash_jumper: false, **rest)
  "#{path} #{flash_jumper} #{rest.inspect}"
end

options = { cartridge: { flash_jumper: true } }
puts take("y", **options[:cartridge])

def outer(**options)
  puts take("fetch", **options.fetch(:cartridge, {}))
  puts take("fetch-miss", **options.fetch(:missing, {}))
  puts take("index", **options[:cartridge])
  puts take_kw("kw", **options[:cartridge])
  puts take_kw("kw-lit", z: 1, **options[:cartridge])
end
outer(cartridge: { flash_jumper: true, x: 2 })

mixed = { cartridge: { flash_jumper: true, depth: 3 }, n: 3 }
puts take("mixed", **mixed[:cartridge])
puts take_kw("mixed-kw", **mixed[:cartridge])
puts take("two", a: 0, **mixed[:cartridge], **{ b: 1 })
puts take("nil", **mixed[:none])

class Cart
  def load(name, **opts)
    "#{name} #{opts.inspect}"
  end
end
puts Cart.new.load("obj", **mixed[:cartridge])

begin
  take("int", **mixed[:n])
rescue TypeError => e
  puts e.message
end
