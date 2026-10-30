# `obj.send(name, *args)` with a computed name, where the name is also a
# builtin's (Set#add) and some class of the program defines its own `[]`.
# The arms that branch on args' length read args[0], args[1], ... from the
# Array the splat makes of args; with a user `[]` in the program those reads
# took the per-class dispatch, found no class for an Array and raised
# "undefined method '[]' for an instance of Array" before the call ran
# (a Thor command named `add`, which Thor runs with `__send__(name, *args)`).
class Box
  def [](key)
    "box #{key}"
  end
end

class Todo
  def add(title)
    "add #{title.inspect}"
  end

  def delete(title, force = false)
    "delete #{title} force=#{force}"
  end

  def put(title)
    "put #{title}"
  end
end

def run(target, name, args)
  target.send(name, *args)
end

def run_public(target, name, args)
  target.public_send(name, *args)
end

def run_raw(target, name, args = [])
  target.__send__(name, *args)
end

todo = Todo.new
p Box.new[1]
p run(todo, "add", ["milk"])
p run(todo, "add", [1])
p run(todo, "delete", ["milk"])
p run(todo, "delete", ["milk", true])
p run(todo, "put", ["milk"])
p run_public(todo, "add", ["eggs"])
p run_raw(todo, "add", ["tea"])
begin
  run(todo, "add", [])
rescue ArgumentError => e
  puts e.message
end
