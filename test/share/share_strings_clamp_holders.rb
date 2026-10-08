# Clamp returns the selected String itself through every holder.
# Mutations, frozen state and identity must follow that same handle.

class FrozenClamp
  def run
    s = "aabc"
    t = s.clamp("a", "z")
    puts (s.object_id == t.object_id).to_s
    begin
      s.clear
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts (s.object_id == t.object_id).to_s
    p([s, t])
  end
end

FrozenClamp.new.run

class AttributeClamp
  attr_accessor :v

  def run
    self.v = +"aabc"
    t = self.v.clamp("a", "z")
    p([self.v, t])
    begin
      t.upcase!
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    p([self.v, t])
    p([self.v, t])
  end
end

AttributeClamp.new.run

class BlockClamp
  def run
    ["aabc"].each do |s|
      t = s.clamp("a", "z")
      puts s.equal?(t).to_s
      begin
        t.squeeze!
        puts "ok"
      rescue => e
        puts e.class.to_s
      end
      puts s.equal?(t).to_s
        p([s, t])
    end
  end
end

BlockClamp.new.run

class ConstantClamp
  HS = "aab#{ARGV.size}"

  def run
    t = HS.clamp("a", "z")
    puts (HS.object_id == t.object_id).to_s
    begin
      t << "x"
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts (HS.object_id == t.object_id).to_s
    p([HS, t])
  end
end

ConstantClamp.new.run

class ParameterClamp
  def body(s)
    t = s.clamp("a", "z")
    puts (s.object_id == t.object_id).to_s
    begin
      t.concat("y")
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts (s.object_id == t.object_id).to_s
    p([s, t])
  end

  def run
    body("aabc")
  end
end

ParameterClamp.new.run

class CaptureClamp
  def run
    s = "aab#{ARGV.size}"
    f = lambda do
      t = s.clamp("a", "z")
      puts s.equal?(t).to_s
      begin
        t.replace("zz")
        puts "ok"
      rescue => e
        puts e.class.to_s
      end
      puts s.equal?(t).to_s
        p([s, t])
    end
    f.call
  end
end

CaptureClamp.new.run

class ClassVariableClamp
  def run
    @@s = +"aabc"
    t = @@s.clamp("a", "z")
    puts (@@s.object_id == t.object_id).to_s
    begin
      t.sub!("b", "d")
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    puts (@@s.object_id == t.object_id).to_s
    p([@@s, t])
  end
end

ClassVariableClamp.new.run

class ReceiverClamp
  def run
    s = "aab#{ARGV.size}"
    t = s.clamp("a", "z")
    p([s, t])
    begin
      s.setbyte(0, 65)
      puts "ok"
    rescue => e
      puts e.class.to_s
    end
    p([s, t])
    p([s, t])
  end
end

ReceiverClamp.new.run

