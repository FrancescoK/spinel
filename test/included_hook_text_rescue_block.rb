# A rescue clause in a do-block of a hook's class_eval text, spliced into
# the includer, rescues each element's error as it does in the includer's
# own code.
module Hook
  def self.included(base)
    base.class_eval do
      class_eval "def r = [1, 2].map do |v|\n Integer('z')\n rescue ArgumentError\n v * 10\n end"
    end
  end
end

class U
  include Hook
end

p U.new.r
