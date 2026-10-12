# A String bang called on an element of a boxed Array or Hash answers nil when it
# changes nothing, and a String mutator called on that nil is NoMethodError
# naming the mutator (it was FrozenError). The bang goes through the boxed
# receiver's dispatch there, not the typed String bang's. --share-strings
# answers the same, the bang's answer held as the element's handle.
def try(label)
  yield
rescue NoMethodError, FrozenError, IndexError => e
  puts "#{label}: #{e.class}: #{e.message}"
end
arr = ["e", "f"].map { |q| q + " " }
try('Array element strip!.concat') { p(arr[0].strip!.concat("1")) }
try('Array element strip!.concat') { p(arr[0].strip!.concat("1")) }
try('Array element strip!.concat stmt') { arr[0].strip!.concat("1") }
h = { k: "g".dup }
try('Hash value strip!.prepend') { p(h[:k].strip!.prepend(">")) }
try('Hash value strip!.prepend stmt') { h[:k].strip!.prepend(">") }
try('Hash value strip!.insert') { p(h[:k].strip!.insert(0, "-")) }
