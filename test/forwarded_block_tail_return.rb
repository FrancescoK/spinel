# Re-deriving returns keeps a tail conditional's blockless value available
# while earlier callers are typed. Forwarding can take either arm.
def collect_values(xs)
  if block_given?
    out = []
    xs.each { |x| out << yield(x) }
    out
  else
    xs.each
  end
end

def forwarded_values(&b) = collect_values(["a", "bb"], &b)
def forwarded_groups(&b) = ["a", "bb"].group_by(&b)
def forwarded_min(&b) = ["a", "bb"].min_by(&b)

length = ->(s) { s.length }
p forwarded_values(&length)
p(forwarded_values { |s| s.upcase })
p forwarded_values.to_a
p forwarded_groups(&length)
p(forwarded_groups { |s| s.upcase })
p forwarded_groups.to_a
p forwarded_min(&length)
p forwarded_min.to_a
