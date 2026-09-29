# A global read before its first assignment is nil, also when every
# assignment stores a bool, a Symbol, a Class, a Range or a Float.

require "set"
$ready = true
$level = :debug

def flag_report = (p [$flag.nil?, $flag]; puts($flag ? "t" : "f"))
flag_report
$flag = false
flag_report
$flag = true
flag_report

def mode_report = p([$mode.nil?, $mode, $mode.to_s, $mode == nil])
mode_report
$mode = :fast
mode_report

def kind_report = p([$kind.nil?, $kind])
kind_report
$kind = String
kind_report

def span_report = p([$span.nil?, $span])
span_report
$span = (1..3)
span_report

def ratio_report
  x = $ratio
  p [$ratio.nil?, x]
end
ratio_report
$ratio = 0.5
ratio_report

# `||=` on the unset global runs its right-hand side.
def lazy_sym
  $lazy ||= :made
  $lazy
end
p $lazy
p lazy_sym
p $lazy

# The globals the first statements assign read their values.
def ready_report = p([$ready, $level])
ready_report
$ready = false
ready_report
