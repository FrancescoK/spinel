class Metal
  def initialize
    @response = nil
  end

  def response
    @response
  end
end

class Base < Metal
  def params
    @response
  end
end

module UrlFor
  def initialize(...)
    super
    @_url_options = nil
  end

  def url_options
    @_url_options ||= { host: "example.com" }
  end
end

module Rendering
  def initialize(...)
    super
    @_rendered = nil
  end

  def rendered
    @_rendered ||= { body: "" }
  end
end

early = Base.new
p early.params

class Base
  include UrlFor
  include Rendering
end

b = Base.new
p b.params
p b.url_options
p b.response
p b.rendered
k = [Base, Metal].first
p k.new.url_options
