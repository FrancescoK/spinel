# A call over a boxed receiver whose only candidates never settle: the
# name lives in a module nothing includes, and its methods answer only
# through each other (Action Pack's RequestCookieMethods, included by an
# on_load hook, whose bodies are deferred refusals). The inference leaves
# the call untyped, so the poly dispatch had no type to hold its answer
# in and declared an sp_int slot; `request.cookies_digest || "SHA1"` then
# declared the left at the result's type (`const char *_t = <sp_int>`)
# and took it as always truthy. The dispatch answers boxed, and the chain
# tests that box.
module RequestCookieMethods
  def cookies_digest
    digest_header
  end

  def digest_header
    cookies_digest
  end
end

class Env
  def initialize(req)
    @req = req
  end

  def request
    @req
  end
end

class Jar
  def initialize(parent)
    @parent_jar = parent
  end

  def request
    @parent_jar.request
  end

  def digest
    request.cookies_digest || "SHA1"
  end

  def digest_if
    request.cookies_digest && "signed"
  end

  def rotations
    request.cookies_digest || 0
  end

  def raw
    v = request.cookies_digest
    v
  end
end

jar = Jar.new(Env.new(nil))
[:digest, :digest_if, :rotations, :raw].each do |m|
  begin
    p jar.send(m)
  rescue NoMethodError => e
    puts "#{m}: #{e.class} #{e.name}"
  end
end
