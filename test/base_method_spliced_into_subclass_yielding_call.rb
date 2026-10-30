module TagHelper
  def content_tag(name, content = nil, options = nil, &block)
    content = yield if block_given?
    attrs = options ? options.map { |k, v| " #{k}=\"#{v}\"" }.join : ""
    "<#{name}#{attrs}>#{content}</#{name}>"
  end
end

module InstanceTag
  def content_tag(type, options, *)
    type == :select ? super : "[" + super + "]"
  end
end

module FormTagHelper
  def label_tag(name = nil, content = nil, options = nil, &block)
    options ||= {}
    options["for"] = name.to_s unless name.nil?
    content_tag :label, content || name.to_s.capitalize, options, &block
  end
end

class Base
  include FormTagHelper
  include TagHelper
  include InstanceTag

  def initialize(name)
    @name = name
  end

  def render
    raise NotImplementedError
  end
end

class Label < Base
  def render(&block)
    content = block_given? ? yield : @name.capitalize
    label_tag(@name, content, {})
  end
end

module SelectRenderer
  include TagHelper
end

class Select < Base
  include SelectRenderer

  def render
    content_tag(:select, "opts", { "name" => @name })
  end
end

tags = [Label.new("title"), Select.new("kind")]
tags.each { |t| puts t.render }
puts Label.new("body").render { "Blocky" }
