# The include is in a reopening of a class nested in a module's body, and
# names a module that reopening defines; a method defined ahead of it calls
# the method on a receiver of unknown class, and a statement between runs
# it on another class's object. Each call picks by whether the include has
# run: Plain's own warn first, Reporting's once Reporter has it. Rails'
# Deprecation includes Reporting so, after `require`s that reopen it.
module NS
  class Reporter
    DEFAULT = :stderr
  end
end
def report(logger) = logger.warn("w")
class Plain
  def warn(msg) = puts("plain #{msg}")
end
report(Plain.new)
module NS
  class Reporter
    module Reporting
      def warn(msg) = puts("reported #{msg} to #{DEFAULT}")
    end
    include Reporting
    def self.instance = @instance ||= new
  end
end
report(NS::Reporter.instance)
report(Plain.new)
