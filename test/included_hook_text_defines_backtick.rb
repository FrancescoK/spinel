# A hook's class_eval text that defines ` in the includer makes every
# backtick literal self reaches there a call of it: the one in the text and
# the includer's own.
module Hook
  def self.included(base)
    base.class_eval do
      class_eval 'def `(cmd) = "ran #{cmd}"'
      class_eval 'def from_hook = `echo hook`'
    end
  end
end

class U
  include Hook
  def own = `echo own`
end

p U.new.from_hook
p U.new.own
