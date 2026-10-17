# The answer of `super` passed to a call is a new String when the parent's
# method builds one, read as a direct call's answer is: the formatter that
# scrubs what its parent renders hands the line on, and a String the
# program holds is not shared with it.
class Fmt
  def call(sev, msg) = sev.to_s[0, 1] + ": " + msg.to_s + "\n"
end
class Scrub < Fmt
  def call(sev, msg) = scrub(super)
  def scrub(line) = line.gsub(/\d+/, "N")
end
class Keep < Fmt
  def call(sev, msg)
    line = super
    line << "!"
    line
  end
end
f = [Fmt.new, Scrub.new, Keep.new]
held = +"room 12"
out = f.map { |x| x.call(:info, held) }
out[0] << "#"
p out, held
