# A Range of Time objects has no unboxed layout: a Range's bounds are
# sp_int. `(Time.at(0)..)` was built as an Integer Range and the C did not
# compile; it is refused with the limitation named (#8526).
r = (Time.at(0)..)
p r.end
