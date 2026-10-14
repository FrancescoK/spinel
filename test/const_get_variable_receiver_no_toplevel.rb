# recv.const_get(:N) with a receiver known only at run time, when N names
# classes nested in some modules and none at the top level: a module that
# holds N answers its class, any other raises NameError naming the
# receiver, which the error carries as #receiver.

module Admin
  class Panel
    def who = "Admin::Panel"
  end
end

module Shop
  class Panel
    def who = "Shop::Panel"
  end
end

module Empty
end

def panel(mod) = mod.const_get(:Panel)

[Admin, Shop, Empty, Object].each do |mod|
  begin
    puts panel(mod).new.who
  rescue NameError => e
    puts "NameError: #{e.message}"
    p e.receiver
  end
end

found = [Admin, Empty].map do |mod|
  begin
    panel(mod)
  rescue NameError
    nil
  end
end
p found
