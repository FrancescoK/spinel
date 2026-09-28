# A `**nil` proc or lambda refuses keywords; a positional Hash is not
# keywords, so it is a positional (dropped by a proc, an arity error for a
# lambda).

l = ->(a, **nil) { a }
p((l.call(1, k: 1) rescue $!.message))
p((l.call(1, {k: 1}) rescue $!.message))
p l.call(1)
pr = proc { |a, **nil| a }
p((pr.call(1, k: 1) rescue $!.message))
p((pr.call(1, {k: 1}) rescue $!.message))
p pr.call(1)
p pr.call(1, **{})
l0 = ->(**nil) { 0 }
p((l0.call(k: 1) rescue $!.message))
p((l0.call({k: 1}) rescue $!.message))
p l0.call(**{})
p [{k: 1}].map { |a, **nil| a }
p [{k: 1}].map(&pr)
p [[1, {k: 1}]].map(&pr)
def yy = yield(1, {k: 2})
p(yy { |a, **nil| a })
