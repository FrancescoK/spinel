# A send with a computed name in a class method dispatches over the class's
# own `def self.` methods of the name's shape (minitest's plugin hooks:
# `msg = "plugin_#{name}_init"; send msg, options if self.respond_to? msg`).
# It was refused as a runtime method name, and the class methods only the
# send reached were not emitted.
module Plugins
  @extensions = []
  def self.extensions = @extensions
  def self.plugin_pride_init(options) = "pride init #{options[:seed]}"
  def self.plugin_pride_options(opts, options) = "pride options #{opts} #{options[:seed]}"
  def self.plugin_junit_init(options) = "junit init #{options[:seed]}"

  def self.init_plugins(options)
    extensions.map do |name|
      msg = "plugin_#{name}_init"
      next "no #{msg}" unless self.respond_to? msg
      send msg, options
    end
  end

  def self.process_args(options)
    extensions.map do |meth|
      msg = "plugin_#{meth}_options"
      respond_to?(msg) ? send(msg, "OPTS", options) : "no #{msg}"
    end
  end

  def self.call(name) = public_send("plugin_#{name}_init", {seed: 0})
end

Plugins.extensions << "pride" << "junit" << "minitest"
p Plugins.init_plugins({seed: 1})
p Plugins.process_args({seed: 2})
p Plugins.call("junit")
begin
  Plugins.call("nope")
rescue NoMethodError => e
  p e.class
end
