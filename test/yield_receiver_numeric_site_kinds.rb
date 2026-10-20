# A numeric builtin on a yield, with an Integer block at one call site and a
# Float block at another, answers each site in its own kind. The yield used
# to take its first site's kind, so `7 ** 2` printed 49.0 and `2.5 ** 2` (first
# site Integer) printed 4. CRuby: 49 / 6.25, 7 / 2.5, 1 / 0.5, and so on.
def t_pow = yield.**(2)
def t_conj = yield.conj
def t_modulo = yield.modulo(2)
def t_ceil = yield.ceil(2)
def t_abs2 = yield.abs2
def t_floor = yield.floor(1)
def t_remainder = yield.remainder(2)

p t_pow { 7 }
p t_pow { 2.5 }
p t_pow { 2 ** 70 }
p t_pow { 2.5 }
p t_pow { 7 }
p t_conj { 7 }
p t_conj { 2.5 }
p t_modulo { 7 }
p t_modulo { 2.5 }
p t_ceil { 7 }
p t_ceil { 2.5 }
p t_abs2 { 2 ** 70 }
p t_abs2 { 7 }
p t_abs2 { 2.5 }
p t_floor { 7 }
p t_floor { 2.5 }
p t_remainder { 7 }
p t_remainder { 2.5 }
