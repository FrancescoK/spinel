# diff_classify.rb -- the label `spinel diff` puts on a comparison, and the
# exit status that label maps to. One function over the observations, so the
# order of precedence is in one place and tested as a unit
# (test/tools_diff_classify.rb). Written in the spinel subset.
#
# Labels, in the order they are decided:
#   compile-error    spinel refused the program (no C came out)
#   link-error       the C came out but cc did not build it
#   crash            either spinel run ended on a signal
#   timeout          any run passed the time limit (never counted as a pass)
#   nondeterministic the spinel binary disagreed with its own second run
#   exception-diff   the uncaught exception differs (presence, class, message)
#   output-diff      both ran to an end and stdout or the exit status differs
#   same             no difference
# `known-gap` is decided by the caller from the minimized program (B-2).
#
# Exit status: 0 same, 1 a difference (output-diff, exception-diff, timeout,
# nondeterministic), 2 compile-error / link-error, 3 crash, 4 the tool's own
# error. CI reads these; they are a contract.

# One run's observations. `status` is the exit status (-1 when it did not
# run), `signal` the terminating signal name or "" , `timed_out` 1/0.
class DiffRun
  attr_reader :stdout, :stderr, :status, :signal, :timed_out
  def initialize(stdout, stderr, status, signal, timed_out)
    @stdout = stdout
    @stderr = stderr
    @status = status
    @signal = signal
    @timed_out = timed_out
  end
end

# `compile_ok` / `link_ok`: did the spinel side get a binary. `ref` and `got`
# are the reference (CRuby) and spinel runs with NORMALIZED stdout and the
# normalized exception line in stderr; `got2` is spinel's second run (nil
# when there was none). Answers the label.
def dc_classify(compile_ok, link_ok, ref, got, got2)
  return "compile-error" if !compile_ok
  return "link-error" if !link_ok
  return "crash" if got.signal.length > 0 || (got2 && got2.signal.length > 0)
  return "timeout" if got.timed_out == 1 || ref.timed_out == 1 || (got2 && got2.timed_out == 1)
  if got2 && (got2.stdout != got.stdout || got2.stderr != got.stderr || got2.status != got.status)
    return "nondeterministic"
  end
  return "exception-diff" if ref.stderr != got.stderr
  return "output-diff" if ref.stdout != got.stdout || ref.status != got.status
  "same"
end

# The exit status for a label.
def dc_exit_code(label)
  return 0 if label == "same"
  return 2 if label == "compile-error" || label == "link-error"
  return 3 if label == "crash"
  1
end
