# The finalizers still registered when the program ends run before the C
# exit handlers -- a library's own teardown among them -- with or without
# at_exit hooks. Without hooks they ran from the atexit fallback, after a
# handler registered later than it, and a release into a library already
# torn down crashed (onnxruntime's ReleaseEnv).
module Probe
  ffi_source <<~C
    #include <stdlib.h>
    static int torn_down;
    static void teardown(void) { torn_down = 1; }
    int probe_arm(void) { atexit(teardown); return 0; }
    int probe_torn_down(void) { return torn_down; }
  C
  ffi_func :probe_arm, [], :int
  ffi_func :probe_torn_down, [], :int
end
class Res
  def initialize = ObjectSpace.define_finalizer(self, self.class.release)
  def self.release = proc { |_id| puts "released, library torn down: #{Probe.probe_torn_down}" }
end
keep = Res.new
Probe.probe_arm
puts "end"
