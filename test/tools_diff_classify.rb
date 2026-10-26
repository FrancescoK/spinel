# The label `spinel diff` puts on a comparison and the exit status it maps to
# (tools/diff_classify.rb): the precedence compile-error, link-error, crash,
# timeout, nondeterministic, exception-diff, output-diff, same, and the
# 0 / 1 / 2 / 3 contract CI reads.
require_relative "../tools/diff_classify"

def run(out, err, st, sig = "", to = 0) = DiffRun.new(out, err, st, sig, to)
ok = run("a\n", "", 0)
def show(label) = puts(label + " -> " + dc_exit_code(label).to_s)

show dc_classify(false, false, ok, run("", "", -1), nil)
show dc_classify(true, false, ok, run("", "", -1), nil)
show dc_classify(true, true, ok, run("", "", -1, "SIGSEGV"), nil)
show dc_classify(true, true, ok, run("", "", -1, "", 1), nil)
show dc_classify(true, true, run("", "", -1, "", 1), ok, nil)
show dc_classify(true, true, ok, run("b\n", "", 0), run("c\n", "", 0))
show dc_classify(true, true, ok, run("a\n", "RuntimeError: x", 1), run("a\n", "RuntimeError: x", 1))
show dc_classify(true, true, ok, run("b\n", "", 0), run("b\n", "", 0))
show dc_classify(true, true, ok, run("a\n", "", 1), nil)
show dc_classify(true, true, ok, run("a\n", "", 0), nil)
show dc_classify(true, true, run("a\n", "E: m", 1), run("a\n", "E: m", 1), nil)
# a crash outranks a timeout of the reference, and the signal is what says crash
show dc_classify(true, true, run("", "", -1, "", 1), run("", "", -1, "SIGABRT"), nil)
# The confirmation run's crash or timeout outranks an output difference too.
show dc_classify(true, true, ok, run("b\n", "", 0), run("", "", -1, "SIGABRT"))
show dc_classify(true, true, ok, run("b\n", "", 0), run("", "", -1, "", 1))
# A second-run crash still outranks a reference timeout.
show dc_classify(true, true, run("", "", -1, "", 1), ok, run("", "", -1, "SIGABRT"))
