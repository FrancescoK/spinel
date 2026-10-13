# Loaded with `ruby -r` before a program: records, for every call of a
# Ruby-defined method, the call site and the receiver's class, so
# tools/cls_fact_check.rb can hold spinel's class facts (#8530) against
# what CRuby saw. One line per distinct observation, tab separated:
#   path  line  method  receiver  file-the-receiver's-class-was-defined-in  callee-file
# The receiver is the class name, or Class(X) for a class receiver. The
# callee's file tells a program method from CRuby's own Ruby-defined ones
# (`<internal:kernel>`'s #class, #tap, ...). A call a C method of CRuby
# makes back into the program (Array#== calling an element's #==) is
# recorded with the callee file prefixed by "callback:": its receiver is
# not the receiver of the call written on the line.
out = File.open(ENV.fetch("CLS_FACT_TRACE_OUT"), "a")
out.sync = true
seen = {}
# Kernel's own, so a program's #class or #is_a? (or a BasicObject) does not answer
k_class = Kernel.instance_method(:class)
k_is_a = Kernel.instance_method(:is_a?)
c_methods = {}
c_method = lambda do |label|
  c_methods.fetch(label) do
    c_methods[label] = begin
      m = label.match(/\A([A-Z][\w:]*)([#.])(.+)\z/)
      k = m && Object.const_get(m[1])
      um = m && (m[2] == "#" ? k.instance_method(m[3]) : k.method(m[3]))
      um ? um.source_location.nil? : false
    rescue StandardError
      false
    end
  end
end
TracePoint.new(:call) do |tp|
  loc = caller_locations(2, 1)&.first
  next unless loc
  path = loc.absolute_path || loc.path
  next unless path
  recv = tp.self
  mod = k_is_a.bind_call(recv, Module)
  name = (mod ? recv : k_class.bind_call(recv)).name
  next unless name
  shown = mod ? "Class(#{name})" : name
  key = [path, loc.lineno, tp.method_id, shown, tp.path]
  next if seen[key]
  seen[key] = true
  src = (Object.const_source_location(name) rescue nil)&.first || ""
  callee = c_method.(loc.label) ? "callback:#{tp.path}" : tp.path
  out.puts [path, loc.lineno, tp.method_id, shown, src, callee].join("\t")
end.enable
