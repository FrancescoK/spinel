# catch/throw take nil, true and false as tags: each is a single object, so a
# throw reaches the catch of the same one and no other (not 0, not 1, not each other).
p catch(false) { throw false, 7 }
p catch(nil) { throw(nil, 1) }
p catch(true) { throw true, :yes }
p catch(nil) { throw nil }
p catch(false) { 5 }
p catch(true) { throw true, [1, 2] }

def tried
  p yield
rescue UncaughtThrowError => e
  p e.class
end

tried { catch(false) { throw true, 1 } }
tried { catch(nil) { throw false, 1 } }
tried { catch(0) { throw false, 1 } }
tried { catch(1) { throw true, 1 } }
tried { catch(false) { throw 0, 1 } }
tried { catch(nil) { throw :nil, 1 } }
tried { catch(:nil) { throw nil, 1 } }
tried { catch("false") { throw false, 1 } }
tried { catch(true) { throw nil, 1 } }

# nested: the innermost catch of the tag takes the throw
p catch(nil) { catch(false) { throw nil, :inner_miss }; :not_reached }
p catch(false) { catch(nil) { throw false, :out } ; :not_reached }
p catch(true) { catch(true) { throw true, 5 } + 1 }
p catch(nil) { [1, 2].each { |x| throw nil, x * 10 if x == 2 }; :none }

# from variables and method results
t = nil
f = false
y = true
p catch(t) { throw t, :t }
p catch(f) { throw f, :f }
p catch(y) { throw y, :y }
def flag = 1 > 2
p catch(flag) { throw false, :flag }
p catch(flag) { throw flag, :call }

# a tag held in a box
tags = [nil, false, true, :s, 3, "str"]
tags.each { |tag| p catch(tag) { throw tag, tag.inspect } }
tried { catch(tags[0]) { throw tags[1], 1 } }

# the tag of a block without one is a fresh object
r = catch { |tag| throw tag, :own }
p r

# ensure runs on the way out
log = []
catch(nil) do
  begin
    throw nil
  ensure
    log << :ensure
  end
end
p log

# a tag held in a boxed value meets the same tag written in the program, both ways
ts = [nil, false, true, :s, 0, 1, -1]
p catch(true) { throw ts[2], :t }
p catch(ts[0]) { throw nil, :n }
p catch(ts[1]) { throw false, :f }
tried { catch(true) { throw ts[1], 1 } }
tried { catch(ts[0]) { throw false, 1 } }
tried { catch(ts[4]) { throw ts[1], 1 } }
tried { catch(ts[1]) { throw ts[4], 1 } }
tried { catch(ts[5]) { throw ts[2], 1 } }
tried { catch(ts[6]) { throw ts[0], 1 } }
ts.each_with_index do |a, i|
  ts.each_with_index do |b, j|
    r = begin
      catch(a) { throw b, :hit }
    rescue UncaughtThrowError
      :miss
    end
    print i == j ? (r == :hit ? "=" : "!") : (r == :miss ? "." : "?")
  end
  puts
end

# an object that is nil meets a nil tag, in both directions
class Foo; end
x = nil
x = Foo.new if ARGV.size > 5
p catch(ts[0]) { throw x, :v }
p catch(x) { throw ts[0], :v }
p catch(x) { throw nil, :lit }
p catch(nil) { throw x, :lit2 }
