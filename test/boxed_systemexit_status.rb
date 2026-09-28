# status and success? on a SystemExit read out of a container answer its
# exit status and whether it is 0, as on a typed SystemExit.
def caught(code)
  exit code
rescue SystemExit => e
  e
end
x = [caught(2), 0][0]
p x.status
p x.success?
y = [caught(0), 0][0]
p [y.status, y.success?]
s1 = [SystemExit.new(true), 0][0]
s2 = [SystemExit.new(false), 0][0]
p [s1.status, s1.success?, s2.status, s2.success?]
z = [RuntimeError.new("r"), 0][0]
p (z.status rescue $!.message)
p (z.success? rescue $!.message)
# the NoMethodError names its receiver
p((begin; z.status; rescue NoMethodError => e; e.receiver.equal?(z); end))
