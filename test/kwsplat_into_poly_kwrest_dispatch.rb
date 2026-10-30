# A `**options` double-splat into a `**kwrest` parameter of a method the
# receiver's class dispatches on (a subclass overrides it), where the base
# method holds its kwrest boxed because it reassigns it a value of another
# class: the collected hash is boxed for the dispatch's shared temp.
class Store
  def write(value, **options)
    payload = serialize_entry(value, **options)
    puts payload
  end

  def merged_options(call_options)
    [call_options, nil].compact.first
  end

  def serialize_entry(entry, **options)
    options = merged_options(options)
    "#{entry}:#{options.inspect}"
  end
end

class LocalStore < Store
  def serialize_entry(entry, **options)
    "local " + super
  end
end

Store.new.write(1, x: 2)
Store.new.write("b", namespace: "ns")
LocalStore.new.write(3)
LocalStore.new.write("d", k: 1)
