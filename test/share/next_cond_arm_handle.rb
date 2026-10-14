# A `next` written as an arm of a conditional that is the value of a block
# hands on the String it names, not a copy of it: the block's value is the
# very String the variable holds, so appending to the result changes the
# variable (CRuby prints "ABC9" and true for each shape that takes the `next`,
# and the untouched "abc" and false for the one that does not). The
# conditional's arms were read for a handle without the `next` arm, so a
# ternary, an if/else, an unless or a case whose `next` arm held the handle
# was taken whole as bytes and wrapped in a new String. Under --share-strings
# only: the default build answers a copy for a String the block hands on.
# A `next` that is not where the block's value is (an operand, an argument,
# the right of an assignment, each followed by more statements) leaves the
# block from where it is, and a case/in is a conditional whose arms hand on
# their Strings too, and so is a write the block or its `next` names (`next (u =
# t)`, `next (@x = t)`, `next (h[:k] = t)`).
def one(x) = x
H2 = {}
class H3
  attr_accessor :a
end
def y_write_tail(x) = yield(x)
def y_write_tern(x) = yield(x)
def y_write_next_tern(x) = yield(x)
def y_write_next_bare(x) = yield(x)
def y_write_next_stmt(x) = yield(x)
def y_write_next_mod(x) = yield(x)
def y_write_next_chain(x) = yield(x)
def y_write_next_ivar(x) = yield(x)
def y_write_next_hash(x) = yield(x)
def y_write_next_gvar(x) = yield(x)
def y_write_next_orasg(x) = yield(x)
def y_write_next_attr(x) = yield(x)
def y_write_next_operand(x) = yield(x)
def y_asg_tern(x) = yield(x)
def y_asg_tern_call(x) = yield(x)
def y_asg_unless_else(x) = yield(x)
def y_arg_tern(x) = yield(x)
def y_array_tern(x) = yield(x)
def y_or_operand(x) = yield(x)
def y_or_operand_call(x) = yield(x)
def y_and_operand_call(x) = yield(x)
def y_and_paren(x) = yield(x)
def y_in_plain(x) = yield(x)
def y_in_next(x) = yield(x)
def y_in_next_else(x) = yield(x)
def y_in_bind_next(x) = yield(x)
def y_in_no_else(x) = yield(x)
def y_in_guard(x) = yield(x)
def y_in_array(x) = yield(x)
def y_in_hash(x) = yield(x)
def y_in_alt(x) = yield(x)
def y_in_assigned(x) = yield(x)
def y_in_in_ternary(x) = yield(x)
def y_in_stmt_next(x) = yield(x)
def y_nested(x) = yield(x)
def y_nested2(x) = yield(x)
def y_inner(x) = yield(x)
def y_inner2(x) = yield(x)
def y_tern_then(x) = yield(x)
def y_tern_else(x) = yield(x)
def y_tern_both(x) = yield(x)
def y_tern_not_taken(x) = yield(x)
def y_tern_call(x) = yield(x)
def y_tern_paren(x) = yield(x)
def y_tern_alias(x) = yield(x)
def y_tern_nested(x) = yield(x)
def y_if_else(x) = yield(x)
def y_if_else_taken_else(x) = yield(x)
def y_unless_else(x) = yield(x)
def y_case_when(x) = yield(x)
def y_case_when_both(x) = yield(x)
def y_stmt_if(x) = yield(x)
def y_mod_if(x) = yield(x)
def y_and_tail(x) = yield(x)
def y_nested(x) = yield(x)
def y_inner(x) = yield(x)

s_tern_then = +"abc"
w_tern_then = y_tern_then(s_tern_then) { |t|
  t.upcase! ? (next t) : +"zz"
}
w_tern_then << "9"
puts "tern_then: #{[s_tern_then, w_tern_then.equal?(s_tern_then)].inspect}"

s_tern_else = +"abc"
w_tern_else = y_tern_else(s_tern_else) { |t|
  !t.upcase! ? +"zz" : (next t)
}
w_tern_else << "9"
puts "tern_else: #{[s_tern_else, w_tern_else.equal?(s_tern_else)].inspect}"

s_tern_both = +"abc"
w_tern_both = y_tern_both(s_tern_both) { |t|
  t.upcase! ? (next t) : (next t)
}
w_tern_both << "9"
puts "tern_both: #{[s_tern_both, w_tern_both.equal?(s_tern_both)].inspect}"

s_tern_not_taken = +"abc"
w_tern_not_taken = y_tern_not_taken(s_tern_not_taken) { |t|
  t.size > 5 ? (next t) : +"zz"
}
w_tern_not_taken << "9"
puts "tern_not_taken: #{[s_tern_not_taken, w_tern_not_taken.equal?(s_tern_not_taken)].inspect}"

s_tern_call = +"abc"
w_tern_call = y_tern_call(s_tern_call) { |t|
  t.upcase! ? (next one(t)) : +"zz"
}
w_tern_call << "9"
puts "tern_call: #{[s_tern_call, w_tern_call.equal?(s_tern_call)].inspect}"

s_tern_paren = +"abc"
w_tern_paren = y_tern_paren(s_tern_paren) { |t|
  (t.upcase! ? (next t) : +"zz")
}
w_tern_paren << "9"
puts "tern_paren: #{[s_tern_paren, w_tern_paren.equal?(s_tern_paren)].inspect}"

s_tern_alias = +"abc"
w_tern_alias = y_tern_alias(s_tern_alias) { |t|
  u = t
  t.upcase! ? (next u) : +"zz"
}
w_tern_alias << "9"
puts "tern_alias: #{[s_tern_alias, w_tern_alias.equal?(s_tern_alias)].inspect}"

s_tern_nested = +"abc"
w_tern_nested = y_tern_nested(s_tern_nested) { |t|
  t.upcase! ? (t.size > 1 ? (next t) : +"zz") : +"yy"
}
w_tern_nested << "9"
puts "tern_nested: #{[s_tern_nested, w_tern_nested.equal?(s_tern_nested)].inspect}"

s_if_else = +"abc"
w_if_else = y_if_else(s_if_else) { |t|
  if t.upcase! then next t else +"zz" end
}
w_if_else << "9"
puts "if_else: #{[s_if_else, w_if_else.equal?(s_if_else)].inspect}"

s_if_else_taken_else = +"abc"
w_if_else_taken_else = y_if_else_taken_else(s_if_else_taken_else) { |t|
  if !t.upcase! then +"zz" else next t end
}
w_if_else_taken_else << "9"
puts "if_else_taken_else: #{[s_if_else_taken_else, w_if_else_taken_else.equal?(s_if_else_taken_else)].inspect}"

s_unless_else = +"abc"
w_unless_else = y_unless_else(s_unless_else) { |t|
  unless t.upcase! then +"zz" else next t end
}
w_unless_else << "9"
puts "unless_else: #{[s_unless_else, w_unless_else.equal?(s_unless_else)].inspect}"

s_case_when = +"abc"
w_case_when = y_case_when(s_case_when) { |t|
  case t.upcase!
  when nil then +"zz"
  else next t
  end
}
w_case_when << "9"
puts "case_when: #{[s_case_when, w_case_when.equal?(s_case_when)].inspect}"

s_case_when_both = +"abc"
w_case_when_both = y_case_when_both(s_case_when_both) { |t|
  case t.upcase!
  when nil then next +"zz"
  else next t
  end
}
w_case_when_both << "9"
puts "case_when_both: #{[s_case_when_both, w_case_when_both.equal?(s_case_when_both)].inspect}"

s_stmt_if = +"abc"
w_stmt_if = y_stmt_if(s_stmt_if) { |t|
  if t.upcase!
    next t
  end
  +"zz"
}
w_stmt_if << "9"
puts "stmt_if: #{[s_stmt_if, w_stmt_if.equal?(s_stmt_if)].inspect}"

s_mod_if = +"abc"
w_mod_if = y_mod_if(s_mod_if) { |t|
  next t if t.upcase!
  +"zz"
}
w_mod_if << "9"
puts "mod_if: #{[s_mod_if, w_mod_if.equal?(s_mod_if)].inspect}"

s_and_tail = +"abc"
w_and_tail = y_and_tail(s_and_tail) { |t|
  t.upcase! && (next t)
  +"zz"
}
w_and_tail << "9"
puts "and_tail: #{[s_and_tail, w_and_tail.equal?(s_and_tail)].inspect}"

s_then = +"abc"
w_then = s_then.then { |t| t.upcase! ? (next t) : +"zz" }
w_then << "9"
puts "then: #{[s_then, w_then.equal?(s_then)].inspect}"

s_proc = +"abc"
pr = proc { |t| t.upcase! ? (next t) : +"zz" }
w_proc = pr.call(s_proc)
w_proc << "9"
puts "proc: #{[s_proc, w_proc.equal?(s_proc)].inspect}"

s_lambda = +"abc"
la = lambda { |t| t.upcase! ? (next t) : +"zz" }
w_lambda = la.call(s_lambda)
w_lambda << "9"
puts "lambda: #{[s_lambda, w_lambda.equal?(s_lambda)].inspect}"

s_nested = +"abc"
w_nested = y_nested(s_nested) { |t| y_nested2(t) { |u| u.upcase! ? (next u) : +"zz" } }
w_nested << "9"
puts "nested blocks: #{[s_nested, w_nested.equal?(s_nested)].inspect}"

s_inner = +"abc"
w_inner = y_inner(s_inner) { |t| t.upcase! ? (next t) : y_inner2(1) { |k| next +"in#{k}" } }
w_inner << "9"
puts "inner next: #{[s_inner, w_inner.equal?(s_inner)].inspect}"

s_asg_tern = +"abc"
w_asg_tern = y_asg_tern(s_asg_tern) { |t|
  x = (t.upcase! ? (next t) : 1)
  +"zz"
}
w_asg_tern << "9"
puts "asg_tern: #{[s_asg_tern, w_asg_tern.equal?(s_asg_tern)].inspect}"

s_asg_tern_call = +"abc"
w_asg_tern_call = y_asg_tern_call(s_asg_tern_call) { |t|
  x = (t.upcase! ? (next one(t)) : 1)
  +"zz"
}
w_asg_tern_call << "9"
puts "asg_tern_call: #{[s_asg_tern_call, w_asg_tern_call.equal?(s_asg_tern_call)].inspect}"

s_asg_unless_else = +"abc"
w_asg_unless_else = y_asg_unless_else(s_asg_unless_else) { |t|
  x = (!t.upcase! ? 1 : (next t))
  +"zz"
}
w_asg_unless_else << "9"
puts "asg_unless_else: #{[s_asg_unless_else, w_asg_unless_else.equal?(s_asg_unless_else)].inspect}"

s_arg_tern = +"abc"
w_arg_tern = y_arg_tern(s_arg_tern) { |t|
  one(t.upcase! ? (next t) : 5)
  +"zz"
}
w_arg_tern << "9"
puts "arg_tern: #{[s_arg_tern, w_arg_tern.equal?(s_arg_tern)].inspect}"

s_array_tern = +"abc"
w_array_tern = y_array_tern(s_array_tern) { |t|
  y = [t.upcase! ? (next t) : 5]
  +"zz"
}
w_array_tern << "9"
puts "array_tern: #{[s_array_tern, w_array_tern.equal?(s_array_tern)].inspect}"

s_or_operand = +"abc"
w_or_operand = y_or_operand(s_or_operand) { |t|
  !t.upcase! || (next t)
  +"zz"
}
w_or_operand << "9"
puts "or_operand: #{[s_or_operand, w_or_operand.equal?(s_or_operand)].inspect}"

s_or_operand_call = +"abc"
w_or_operand_call = y_or_operand_call(s_or_operand_call) { |t|
  !t.upcase! || (next one(t))
  +"zz"
}
w_or_operand_call << "9"
puts "or_operand_call: #{[s_or_operand_call, w_or_operand_call.equal?(s_or_operand_call)].inspect}"

s_and_operand_call = +"abc"
w_and_operand_call = y_and_operand_call(s_and_operand_call) { |t|
  t.upcase! && (next one(t))
  +"zz"
}
w_and_operand_call << "9"
puts "and_operand_call: #{[s_and_operand_call, w_and_operand_call.equal?(s_and_operand_call)].inspect}"

s_and_paren = +"abc"
w_and_paren = y_and_paren(s_and_paren) { |t|
  w = (t.upcase! and (next t))
  +"zz"
}
w_and_paren << "9"
puts "and_paren: #{[s_and_paren, w_and_paren.equal?(s_and_paren)].inspect}"

s_in_plain = +"abc"
w_in_plain = y_in_plain(s_in_plain) { |t|
  case t.size
  in 3 then (t.upcase!; t)
  else +"zz"
  end
}
w_in_plain << "9"
puts "in_plain: #{[s_in_plain, w_in_plain.equal?(s_in_plain)].inspect}"

s_in_next = +"abc"
w_in_next = y_in_next(s_in_next) { |t|
  case t.size
  in 3 then (t.upcase!; next t)
  else +"zz"
  end
}
w_in_next << "9"
puts "in_next: #{[s_in_next, w_in_next.equal?(s_in_next)].inspect}"

s_in_next_else = +"abc"
w_in_next_else = y_in_next_else(s_in_next_else) { |t|
  case t.size
  in 4 then +"zz"
  else (t.upcase!; next t)
  end
}
w_in_next_else << "9"
puts "in_next_else: #{[s_in_next_else, w_in_next_else.equal?(s_in_next_else)].inspect}"

s_in_bind_next = +"abc"
w_in_bind_next = y_in_bind_next(s_in_bind_next) { |t|
  case t
  in String => u then (u.upcase!; next u)
  end
}
w_in_bind_next << "9"
puts "in_bind_next: #{[s_in_bind_next, w_in_bind_next.equal?(s_in_bind_next)].inspect}"

s_in_no_else = +"abc"
w_in_no_else = y_in_no_else(s_in_no_else) { |t|
  case t.size
  in 3 then (t.upcase!; t)
  in 4 then +"zz"
  end
}
w_in_no_else << "9"
puts "in_no_else: #{[s_in_no_else, w_in_no_else.equal?(s_in_no_else)].inspect}"

s_in_guard = +"abc"
w_in_guard = y_in_guard(s_in_guard) { |t|
  case t.size
  in Integer => n if n > 2 then (t.upcase!; t)
  else +"zz"
  end
}
w_in_guard << "9"
puts "in_guard: #{[s_in_guard, w_in_guard.equal?(s_in_guard)].inspect}"

s_in_array = +"abc"
w_in_array = y_in_array(s_in_array) { |t|
  case [t.size, 1]
  in [3, x] then (t.upcase!; t)
  else +"zz"
  end
}
w_in_array << "9"
puts "in_array: #{[s_in_array, w_in_array.equal?(s_in_array)].inspect}"

s_in_hash = +"abc"
w_in_hash = y_in_hash(s_in_hash) { |t|
  case {a: t.size}
  in {a: 3} then (t.upcase!; t)
  else +"zz"
  end
}
w_in_hash << "9"
puts "in_hash: #{[s_in_hash, w_in_hash.equal?(s_in_hash)].inspect}"

s_in_alt = +"abc"
w_in_alt = y_in_alt(s_in_alt) { |t|
  case t.size
  in 1 | 3 then (t.upcase!; t)
  else +"zz"
  end
}
w_in_alt << "9"
puts "in_alt: #{[s_in_alt, w_in_alt.equal?(s_in_alt)].inspect}"

s_in_assigned = +"abc"
w_in_assigned = y_in_assigned(s_in_assigned) { |t|
  x = case t.size
  in 3 then (t.upcase!; t)
  else +"zz"
  end
  x
}
w_in_assigned << "9"
puts "in_assigned: #{[s_in_assigned, w_in_assigned.equal?(s_in_assigned)].inspect}"

s_in_in_ternary = +"abc"
w_in_in_ternary = y_in_in_ternary(s_in_in_ternary) { |t|
  t.upcase! ? (case t.size
  in 3 then t
  else +"zz"
  end) : +"yy"
}
w_in_in_ternary << "9"
puts "in_in_ternary: #{[s_in_in_ternary, w_in_in_ternary.equal?(s_in_in_ternary)].inspect}"

s_in_stmt_next = +"abc"
w_in_stmt_next = y_in_stmt_next(s_in_stmt_next) { |t|
  case t.size
  in 3
    t.upcase!
    next t
  else
    nil
  end
  +"zz"
}
w_in_stmt_next << "9"
puts "in_stmt_next: #{[s_in_stmt_next, w_in_stmt_next.equal?(s_in_stmt_next)].inspect}"

s_in_proc = +"abc"
pr_in = proc { |t| t.upcase! ? (case t.size
  in 3 then t
  else +"zz"
  end) : +"yy" }
w_in_proc = pr_in.call(s_in_proc)
w_in_proc << "9"
puts "in_proc: #{[s_in_proc, w_in_proc.equal?(s_in_proc)].inspect}"

class Pick
  def initialize(s); @s = s; end
  def pick(n)
    case n
    in 1 then @s
    in 2 then (@s << "!"; @s)
    else +"zz"
    end
  end
end
pk = Pick.new(+"abc")
x_pick = pk.pick(1)
x_pick << "1"
y_pick = pk.pick(2)
z_pick = pk.pick(3)
puts "pick: #{[x_pick, y_pick, z_pick, x_pick.equal?(y_pick), z_pick.equal?(x_pick)].inspect}"

s_write_tail = +"abc"
w_write_tail = y_write_tail(s_write_tail) { |t|
  u = t
}
w_write_tail << "9"
puts "write_tail: #{[s_write_tail, w_write_tail.equal?(s_write_tail)].inspect}"

s_write_tern = +"abc"
w_write_tern = y_write_tern(s_write_tern) { |t|
  t.upcase! ? (u = t) : +"zz"
}
w_write_tern << "9"
puts "write_tern: #{[s_write_tern, w_write_tern.equal?(s_write_tern)].inspect}"

s_write_next_tern = +"abc"
w_write_next_tern = y_write_next_tern(s_write_next_tern) { |t|
  t.upcase! ? (next (u = t)) : +"zz"
}
w_write_next_tern << "9"
puts "write_next_tern: #{[s_write_next_tern, w_write_next_tern.equal?(s_write_next_tern)].inspect}"

s_write_next_bare = +"abc"
w_write_next_bare = y_write_next_bare(s_write_next_bare) { |t|
  t.upcase! ? (next u = t) : +"zz"
}
w_write_next_bare << "9"
puts "write_next_bare: #{[s_write_next_bare, w_write_next_bare.equal?(s_write_next_bare)].inspect}"

s_write_next_stmt = +"abc"
w_write_next_stmt = y_write_next_stmt(s_write_next_stmt) { |t|
  if t.upcase!
    next (u = t)
  end
  +"zz"
}
w_write_next_stmt << "9"
puts "write_next_stmt: #{[s_write_next_stmt, w_write_next_stmt.equal?(s_write_next_stmt)].inspect}"

s_write_next_mod = +"abc"
w_write_next_mod = y_write_next_mod(s_write_next_mod) { |t|
  next (u = t) if t.upcase!
  +"zz"
}
w_write_next_mod << "9"
puts "write_next_mod: #{[s_write_next_mod, w_write_next_mod.equal?(s_write_next_mod)].inspect}"

s_write_next_chain = +"abc"
w_write_next_chain = y_write_next_chain(s_write_next_chain) { |t|
  next (u = t << "x") if t.upcase!
  +"zz"
}
w_write_next_chain << "9"
puts "write_next_chain: #{[s_write_next_chain, w_write_next_chain.equal?(s_write_next_chain)].inspect}"

s_write_next_ivar = +"abc"
w_write_next_ivar = y_write_next_ivar(s_write_next_ivar) { |t|
  next (@x = t) if t.upcase!
  +"zz"
}
w_write_next_ivar << "9"
puts "write_next_ivar: #{[s_write_next_ivar, w_write_next_ivar.equal?(s_write_next_ivar)].inspect}"

s_write_next_hash = +"abc"
w_write_next_hash = y_write_next_hash(s_write_next_hash) { |t|
  next (H2[:k] = t) if t.upcase!
  +"zz"
}
w_write_next_hash << "9"
puts "write_next_hash: #{[s_write_next_hash, w_write_next_hash.equal?(s_write_next_hash)].inspect}"

s_write_next_gvar = +"abc"
w_write_next_gvar = y_write_next_gvar(s_write_next_gvar) { |t|
  next ($g = t) if t.upcase!
  +"zz"
}
w_write_next_gvar << "9"
puts "write_next_gvar: #{[s_write_next_gvar, w_write_next_gvar.equal?(s_write_next_gvar)].inspect}"

s_write_next_orasg = +"abc"
w_write_next_orasg = y_write_next_orasg(s_write_next_orasg) { |t|
  u = +"q"
  next (u ||= t) if t.upcase!
  +"zz"
}
w_write_next_orasg << "9"
puts "write_next_orasg: #{[s_write_next_orasg, w_write_next_orasg.equal?(s_write_next_orasg)].inspect}"

s_write_next_attr = +"abc"
w_write_next_attr = y_write_next_attr(s_write_next_attr) { |t|
  next (H3.new.a = t) if t.upcase!
  +"zz"
}
w_write_next_attr << "9"
puts "write_next_attr: #{[s_write_next_attr, w_write_next_attr.equal?(s_write_next_attr)].inspect}"

s_write_next_operand = +"abc"
w_write_next_operand = y_write_next_operand(s_write_next_operand) { |t|
  x = (t.upcase! ? (next (u = t)) : 1)
  +"zz"
}
w_write_next_operand << "9"
puts "write_next_operand: #{[s_write_next_operand, w_write_next_operand.equal?(s_write_next_operand)].inspect}"
