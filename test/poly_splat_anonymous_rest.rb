class Callback
  def call(object, context = {}, *, &) = [:cb, object, context]
end

class State
  def call(object, method, *args, &) = [:st, object, method, args]
end

class Forward
  def call(object, *, **, &) = [:fw, object, rest(*), opts(**)]
  def rest(*r) = r
  def opts(**o) = o
end

class Post
  def call(a, *, z) = [:post, a, rest(*), z]
  def rest(*r) = r
end

def run(pr, *args, **)
  pr.call(*args, **)
end

def run_plain(pr, *args)
  pr.call(*args)
end

p run(proc { |a, b| [a, b] }, 1, 2)
p run(Callback.new, 1, 2, 3)
p run(Callback.new, 1)
p run(State.new, 1, :m, 3)
p run(Forward.new, 1, 2, 3, k: 4)
p run(Post.new, 1, 2, 3, 4)
p run_plain(proc { |a, b| [a, b] }, 1, 2)
p run_plain(Callback.new, 1, 2, 3)
p run_plain(Forward.new, 1, 2)
p run_plain(Post.new, 1, 2)
begin
  run_plain(Post.new, 1)
rescue ArgumentError => e
  p e.message
end
