# A call on a boxed receiver (here an Array, nil or an Integer) runs its
# argument, then raises NoMethodError when the receiver has no such method,
# nil's included, before the method converts an argument that can be nil.
# The TypeError for nil is an Array's own, and include? and count take nil
# as any value. The argument was converted as it was held, ahead of the
# receiver's dispatch, or beside the receiver's check in the helper's
# arguments, where x86-64 gcc converts first, and nil's TypeError came
# ahead of the NoMethodError or of the answer.

$log = []
def note(v) = ($log << v.inspect; v)

def show(label)
  r = begin
    yield.inspect
  rescue NoMethodError, TypeError => e
    "#{e.class} #{e.message}"
  end
  puts "#{label}: #{$log.join(" ")} -> #{r}"
  $log.clear
end

def line(kind)
  case kind
  when :stops then ["Jayang", "Guui", "Kondae", "Achasan"]
  when :fare then 1400
  end
end

def wanted(set) = set ? 2 : nil

def first_ran(a, n) = a.first(note(n))
def first_read(a, n) = a.first(n)
def take_ran(a, n) = a.take(note(n))
def take_read(a, n) = a.take(n)
def drop_ran(a, n) = a.drop(note(n))
def drop_read(a, n) = a.drop(n)
def at_ran(a, n) = a.at(note(n))
def at_read(a, n) = a.at(n)
def fetch_ran(a, n) = a.fetch(note(n))
def fetch_read(a, n) = a.fetch(n)
def values_at_ran(a, n) = a.values_at(note(n))
def values_at_read(a, n) = a.values_at(n)
def include_ran(a, n) = a.include?(note(n))
def include_read(a, n) = a.include?(n)
def count_ran(a, n) = a.count(note(n))
def count_read(a, n) = a.count(n)

[[:stops, true], [:stops, false], [nil, true], [nil, false], [:fare, false]].each do |kind, set|
  a = line(kind)
  n = wanted(set)
  k = "#{a.inspect[0, 9]} #{n.inspect}"
  show("#{k} first") { first_ran(a, n) }
  show("#{k} first, read") { first_read(a, n) }
  show("#{k} take") { take_ran(a, n) }
  show("#{k} take, read") { take_read(a, n) }
  show("#{k} drop") { drop_ran(a, n) }
  show("#{k} drop, read") { drop_read(a, n) }
  show("#{k} at") { at_ran(a, n) }
  show("#{k} at, read") { at_read(a, n) }
  show("#{k} fetch") { fetch_ran(a, n) }
  show("#{k} fetch, read") { fetch_read(a, n) }
  show("#{k} values_at") { values_at_ran(a, n) }
  show("#{k} values_at, read") { values_at_read(a, n) }
  show("#{k} include?") { include_ran(a, n) }
  show("#{k} include?, read") { include_read(a, n) }
  show("#{k} count") { count_ran(a, n) }
  show("#{k} count, read") { count_read(a, n) }
end
