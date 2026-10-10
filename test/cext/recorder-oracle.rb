# Compare recorded definitions with reflection on the same C fixture in CRuby.
require "json"
m = JSON.parse(File.read(ARGV.fetch(0)))
resolve = ->(name) { name.split("::").inject(Object) { |o, n| o.const_get(n, false) } }
m.fetch("definitions").each do |d|
  owner = resolve.call(d.fetch("owner"))
  name = d["name"]
  case d.fetch("kind")
  when "class"
    c = resolve.call(d.fetch("path"))
    raise "class/superclass #{name}" unless c.is_a?(Class) && c.superclass == resolve.call(d.fetch("superclass"))
  when "module"
    raise "module #{name}" unless resolve.call(d.fetch("path")).instance_of?(Module)
  when "method"
    o = d.fetch("scope") == "singleton" ? owner.singleton_class : owner
    raise "visibility #{name}" unless o.send("#{d.fetch('visibility')}_instance_methods", false).include?(name.to_sym)
    actual = o.instance_method(name).arity
    expected = d.fetch("arity") == -2 ? -1 : d.fetch("arity")
    raise "arity #{name}: #{actual} != #{expected}" unless actual == expected
  when "alias"
    raise "alias #{name}" unless owner.instance_method(name) == owner.instance_method(d.fetch("original"))
  when "attribute"
    raise "reader #{name}" if d.fetch("read") && !owner.instance_methods(false).include?(name.to_sym)
    raise "writer #{name}" if d.fetch("write") && !owner.instance_methods(false).include?("#{name}=".to_sym)
  when "include"
    raise "include" unless owner.ancestors.include?(resolve.call(d.fetch("module")))
  when "extend"
    raise "extend" unless owner.singleton_class.ancestors.include?(resolve.call(d.fetch("module")))
  when "constant"
    v = d.fetch("value"); actual = owner.const_get(name, false)
    expected = case v.fetch("type")
               when "nil" then nil
               when "integer", "boolean" then v.fetch("value")
               when "symbol" then v.fetch("value").to_sym
               when "reference" then resolve.call(v.fetch("value"))
               when "string" then [v.fetch("hex")].pack("H*")
               end
    raise "constant #{name}" unless actual == expected
    if v["type"] == "string"
      raise "frozen #{name}" unless actual.frozen? == v.fetch("frozen")
      raise "encoding #{name}" unless actual.encoding == Encoding::BINARY
    end
  end
end
raise "shared constant string identity" unless Sample::BYTES.equal?(Sample::SAME_BYTES)
puts "cext-recorder-oracle: pass"
