# FFI forwards Array-or-nil keep parameters through several native writers.
require "fiddle"
pointer = Fiddle::Pointer["hello"]
p pointer.to_s
