# A self call dispatched over overrides, typed while they answered
# different Hash kinds: the base's `{}` a String => untyped Hash, the
# overrides' a String => String one. The parameter of a method reached only
# through method(:sym) is typed after the fixpoint, which widens @viewer and
# with it both overrides' Hashes, so the switch then answers one Hash kind
# while the call, and the local it is assigned to, stay boxed. The switch's
# answer is boxed into the local, bare and through `self.`.

class Controller
  def view_assigns
    {}
  end

  def view_env
    env = {}
    assigns = view_assigns
    keys = assigns.keys
    i = 0
    while i < keys.size
      env[keys[i]] = assigns[keys[i]]
      i += 1
    end
    env
  end

  def view_keys
    assigns = self.view_assigns
    assigns.keys
  end
end

class AppController < Controller
  def load_viewer
    @viewer = "guest"
  end

  def viewer_from(v)
    @viewer = v
  end

  def view_assigns
    { "viewer" => @viewer }
  end
end

class UsersController < AppController
  def view_assigns
    { "viewer" => @viewer, "role" => "admin" }
  end
end

a = AppController.new
a.load_viewer
p a.view_env
p a.view_keys
u = UsersController.new
u.load_viewer
p u.view_env
p u.view_keys
p Controller.new.view_env
p Controller.new.view_keys
m = u.method(:viewer_from)
p m.arity
