class Flash
  def merge(other)
    self
  end
end

def interrupt(items)
  items.transform_values! { |item| item[:type] == 1 ? item.merge(status: 2) : item }
end

p Flash.new.merge({}).is_a?(Flash)
interrupt({ 1 => { type: 3 } })
p interrupt({ "a" => { type: 1 }, "b" => { type: 3, at: "x" } })

def merge_several(items)
  items.transform_values { |item| item[:type] == 1 ? item.merge({status: 2}, {done: true}) : item }
end

p merge_several({ "a" => { type: 1 }, "b" => { type: 3 } })
