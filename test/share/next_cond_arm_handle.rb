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
# t)`, `next (@x = t)`, `next (h[:k] = t)`). The writes (an instance variable, a
# global, a class variable, an attribute, a Hash element, a chained write, an
# `||=`) are each the block's tail, a `next` operand and a ternary arm, at the
# top level and in a method. A begin (with a rescue, an else or an ensure) is the
# block's value the same way, so is a local's `||=` and `&&=`, and the result held
# as a box (a variable that was an Integer first, a proc's answer) takes the
# handle as well.
def one(x) = x
def y_begin_next(x) = yield(x)
def y_begin_next_stmt(x) = yield(x)
def y_begin_ensure(x) = yield(x)
def y_begin_rescue_body(x) = yield(x)
def y_begin_rescue_arm(x) = yield(x)
def y_begin_else(x) = yield(x)
def y_begin_nested(x) = yield(x)
def y_begin_assigned(x) = yield(x)
def y_begin_unless(x) = yield(x)
def y_begin_case(x) = yield(x)
def y_or_write(x) = yield(x)
def y_and_write(x) = yield(x)
def y_bx_read(x) = yield(x)
def p_bx_read(x) = yield(x)
def y_bx_local_write(x) = yield(x)
def p_bx_local_write(x) = yield(x)
def y_bx_ivar_write(x) = yield(x)
def p_bx_ivar_write(x) = yield(x)
def y_bx_gvar_write(x) = yield(x)
def p_bx_gvar_write(x) = yield(x)
def y_bx_next_write(x) = yield(x)
def p_bx_next_write(x) = yield(x)
def y_bx_tern_write(x) = yield(x)
def p_bx_tern_write(x) = yield(x)
def y_c5(x) = yield(x)
class OA
  attr_accessor :a
end
$g = nil
def y_t_ivar_tail(x) = yield(x)
def y_m_ivar_tail(x) = yield(x)
def y_t_ivar_next(x) = yield(x)
def y_m_ivar_next(x) = yield(x)
def y_t_ivar_tern(x) = yield(x)
def y_m_ivar_tern(x) = yield(x)
def y_t_ivar_tern_next(x) = yield(x)
def y_m_ivar_tern_next(x) = yield(x)
def y_t_gvar_tail(x) = yield(x)
def y_m_gvar_tail(x) = yield(x)
def y_t_gvar_next(x) = yield(x)
def y_m_gvar_next(x) = yield(x)
def y_t_gvar_tern(x) = yield(x)
def y_m_gvar_tern(x) = yield(x)
def y_t_gvar_tern_next(x) = yield(x)
def y_m_gvar_tern_next(x) = yield(x)
def y_t_cvar_tail(x) = yield(x)
def y_m_cvar_tail(x) = yield(x)
def y_t_cvar_next(x) = yield(x)
def y_m_cvar_next(x) = yield(x)
def y_t_cvar_tern(x) = yield(x)
def y_m_cvar_tern(x) = yield(x)
def y_t_cvar_tern_next(x) = yield(x)
def y_m_cvar_tern_next(x) = yield(x)
def y_t_attr_tail(x) = yield(x)
def y_m_attr_tail(x) = yield(x)
def y_t_attr_next(x) = yield(x)
def y_m_attr_next(x) = yield(x)
def y_t_attr_tern(x) = yield(x)
def y_m_attr_tern(x) = yield(x)
def y_t_attr_tern_next(x) = yield(x)
def y_m_attr_tern_next(x) = yield(x)
def y_t_hash_tail(x) = yield(x)
def y_m_hash_tail(x) = yield(x)
def y_t_hash_next(x) = yield(x)
def y_m_hash_next(x) = yield(x)
def y_t_hash_tern(x) = yield(x)
def y_m_hash_tern(x) = yield(x)
def y_t_hash_tern_next(x) = yield(x)
def y_m_hash_tern_next(x) = yield(x)
def y_t_chain_tail(x) = yield(x)
def y_m_chain_tail(x) = yield(x)
def y_t_chain_next(x) = yield(x)
def y_m_chain_next(x) = yield(x)
def y_t_chain_tern(x) = yield(x)
def y_m_chain_tern(x) = yield(x)
def y_t_chain_tern_next(x) = yield(x)
def y_m_chain_tern_next(x) = yield(x)
def y_t_orasg_tail(x) = yield(x)
def y_m_orasg_tail(x) = yield(x)
def y_t_orasg_next(x) = yield(x)
def y_m_orasg_next(x) = yield(x)
def y_t_orasg_tern(x) = yield(x)
def y_m_orasg_tern(x) = yield(x)
def y_t_orasg_tern_next(x) = yield(x)
def y_m_orasg_tern_next(x) = yield(x)
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

s_t_ivar_tail = +"abc"
h_t_ivar_tail = {}
o_t_ivar_tail = OA.new
w_t_ivar_tail = y_t_ivar_tail(s_t_ivar_tail) { |t|
  @x = t
}
w_t_ivar_tail << "9"
puts "top ivar_tail: #{[s_t_ivar_tail, w_t_ivar_tail.equal?(s_t_ivar_tail)].inspect}"

s_t_ivar_next = +"abc"
h_t_ivar_next = {}
o_t_ivar_next = OA.new
w_t_ivar_next = y_t_ivar_next(s_t_ivar_next) { |t|
  next (@x = t) if t.upcase!
  +"zz"
}
w_t_ivar_next << "9"
puts "top ivar_next: #{[s_t_ivar_next, w_t_ivar_next.equal?(s_t_ivar_next)].inspect}"

s_t_ivar_tern = +"abc"
h_t_ivar_tern = {}
o_t_ivar_tern = OA.new
w_t_ivar_tern = y_t_ivar_tern(s_t_ivar_tern) { |t|
  t.upcase! ? (@x = t) : +"zz"
}
w_t_ivar_tern << "9"
puts "top ivar_tern: #{[s_t_ivar_tern, w_t_ivar_tern.equal?(s_t_ivar_tern)].inspect}"

s_t_ivar_tern_next = +"abc"
h_t_ivar_tern_next = {}
o_t_ivar_tern_next = OA.new
w_t_ivar_tern_next = y_t_ivar_tern_next(s_t_ivar_tern_next) { |t|
  t.upcase! ? (next (@x = t)) : +"zz"
}
w_t_ivar_tern_next << "9"
puts "top ivar_tern_next: #{[s_t_ivar_tern_next, w_t_ivar_tern_next.equal?(s_t_ivar_tern_next)].inspect}"

s_t_gvar_tail = +"abc"
h_t_gvar_tail = {}
o_t_gvar_tail = OA.new
w_t_gvar_tail = y_t_gvar_tail(s_t_gvar_tail) { |t|
  $g = t
}
w_t_gvar_tail << "9"
puts "top gvar_tail: #{[s_t_gvar_tail, w_t_gvar_tail.equal?(s_t_gvar_tail)].inspect}"

s_t_gvar_next = +"abc"
h_t_gvar_next = {}
o_t_gvar_next = OA.new
w_t_gvar_next = y_t_gvar_next(s_t_gvar_next) { |t|
  next ($g = t) if t.upcase!
  +"zz"
}
w_t_gvar_next << "9"
puts "top gvar_next: #{[s_t_gvar_next, w_t_gvar_next.equal?(s_t_gvar_next)].inspect}"

s_t_gvar_tern = +"abc"
h_t_gvar_tern = {}
o_t_gvar_tern = OA.new
w_t_gvar_tern = y_t_gvar_tern(s_t_gvar_tern) { |t|
  t.upcase! ? ($g = t) : +"zz"
}
w_t_gvar_tern << "9"
puts "top gvar_tern: #{[s_t_gvar_tern, w_t_gvar_tern.equal?(s_t_gvar_tern)].inspect}"

s_t_gvar_tern_next = +"abc"
h_t_gvar_tern_next = {}
o_t_gvar_tern_next = OA.new
w_t_gvar_tern_next = y_t_gvar_tern_next(s_t_gvar_tern_next) { |t|
  t.upcase! ? (next ($g = t)) : +"zz"
}
w_t_gvar_tern_next << "9"
puts "top gvar_tern_next: #{[s_t_gvar_tern_next, w_t_gvar_tern_next.equal?(s_t_gvar_tern_next)].inspect}"

s_t_attr_tail = +"abc"
h_t_attr_tail = {}
o_t_attr_tail = OA.new
w_t_attr_tail = y_t_attr_tail(s_t_attr_tail) { |t|
  o_t_attr_tail.a = t
}
w_t_attr_tail << "9"
puts "top attr_tail: #{[s_t_attr_tail, w_t_attr_tail.equal?(s_t_attr_tail)].inspect}"

s_t_attr_next = +"abc"
h_t_attr_next = {}
o_t_attr_next = OA.new
w_t_attr_next = y_t_attr_next(s_t_attr_next) { |t|
  next (o_t_attr_next.a = t) if t.upcase!
  +"zz"
}
w_t_attr_next << "9"
puts "top attr_next: #{[s_t_attr_next, w_t_attr_next.equal?(s_t_attr_next)].inspect}"

s_t_attr_tern = +"abc"
h_t_attr_tern = {}
o_t_attr_tern = OA.new
w_t_attr_tern = y_t_attr_tern(s_t_attr_tern) { |t|
  t.upcase! ? (o_t_attr_tern.a = t) : +"zz"
}
w_t_attr_tern << "9"
puts "top attr_tern: #{[s_t_attr_tern, w_t_attr_tern.equal?(s_t_attr_tern)].inspect}"

s_t_attr_tern_next = +"abc"
h_t_attr_tern_next = {}
o_t_attr_tern_next = OA.new
w_t_attr_tern_next = y_t_attr_tern_next(s_t_attr_tern_next) { |t|
  t.upcase! ? (next (o_t_attr_tern_next.a = t)) : +"zz"
}
w_t_attr_tern_next << "9"
puts "top attr_tern_next: #{[s_t_attr_tern_next, w_t_attr_tern_next.equal?(s_t_attr_tern_next)].inspect}"

s_t_hash_tail = +"abc"
h_t_hash_tail = {}
o_t_hash_tail = OA.new
w_t_hash_tail = y_t_hash_tail(s_t_hash_tail) { |t|
  h_t_hash_tail[:k] = t
}
w_t_hash_tail << "9"
puts "top hash_tail: #{[s_t_hash_tail, w_t_hash_tail.equal?(s_t_hash_tail)].inspect}"

s_t_hash_next = +"abc"
h_t_hash_next = {}
o_t_hash_next = OA.new
w_t_hash_next = y_t_hash_next(s_t_hash_next) { |t|
  next (h_t_hash_next[:k] = t) if t.upcase!
  +"zz"
}
w_t_hash_next << "9"
puts "top hash_next: #{[s_t_hash_next, w_t_hash_next.equal?(s_t_hash_next)].inspect}"

s_t_hash_tern = +"abc"
h_t_hash_tern = {}
o_t_hash_tern = OA.new
w_t_hash_tern = y_t_hash_tern(s_t_hash_tern) { |t|
  t.upcase! ? (h_t_hash_tern[:k] = t) : +"zz"
}
w_t_hash_tern << "9"
puts "top hash_tern: #{[s_t_hash_tern, w_t_hash_tern.equal?(s_t_hash_tern)].inspect}"

s_t_hash_tern_next = +"abc"
h_t_hash_tern_next = {}
o_t_hash_tern_next = OA.new
w_t_hash_tern_next = y_t_hash_tern_next(s_t_hash_tern_next) { |t|
  t.upcase! ? (next (h_t_hash_tern_next[:k] = t)) : +"zz"
}
w_t_hash_tern_next << "9"
puts "top hash_tern_next: #{[s_t_hash_tern_next, w_t_hash_tern_next.equal?(s_t_hash_tern_next)].inspect}"

s_t_chain_tail = +"abc"
h_t_chain_tail = {}
o_t_chain_tail = OA.new
w_t_chain_tail = y_t_chain_tail(s_t_chain_tail) { |t|
  x = @y = t
}
w_t_chain_tail << "9"
puts "top chain_tail: #{[s_t_chain_tail, w_t_chain_tail.equal?(s_t_chain_tail)].inspect}"

s_t_chain_next = +"abc"
h_t_chain_next = {}
o_t_chain_next = OA.new
w_t_chain_next = y_t_chain_next(s_t_chain_next) { |t|
  next (x = @y = t) if t.upcase!
  +"zz"
}
w_t_chain_next << "9"
puts "top chain_next: #{[s_t_chain_next, w_t_chain_next.equal?(s_t_chain_next)].inspect}"

s_t_chain_tern = +"abc"
h_t_chain_tern = {}
o_t_chain_tern = OA.new
w_t_chain_tern = y_t_chain_tern(s_t_chain_tern) { |t|
  t.upcase! ? (x = @y = t) : +"zz"
}
w_t_chain_tern << "9"
puts "top chain_tern: #{[s_t_chain_tern, w_t_chain_tern.equal?(s_t_chain_tern)].inspect}"

s_t_chain_tern_next = +"abc"
h_t_chain_tern_next = {}
o_t_chain_tern_next = OA.new
w_t_chain_tern_next = y_t_chain_tern_next(s_t_chain_tern_next) { |t|
  t.upcase! ? (next (x = @y = t)) : +"zz"
}
w_t_chain_tern_next << "9"
puts "top chain_tern_next: #{[s_t_chain_tern_next, w_t_chain_tern_next.equal?(s_t_chain_tern_next)].inspect}"

s_t_orasg_tail = +"abc"
h_t_orasg_tail = {}
o_t_orasg_tail = OA.new
w_t_orasg_tail = y_t_orasg_tail(s_t_orasg_tail) { |t|
  @x ||= t
}
w_t_orasg_tail << "9"
puts "top orasg_tail: #{[s_t_orasg_tail, w_t_orasg_tail.equal?(s_t_orasg_tail)].inspect}"

s_t_orasg_next = +"abc"
h_t_orasg_next = {}
o_t_orasg_next = OA.new
w_t_orasg_next = y_t_orasg_next(s_t_orasg_next) { |t|
  next (@x ||= t) if t.upcase!
  +"zz"
}
w_t_orasg_next << "9"
puts "top orasg_next: #{[s_t_orasg_next, w_t_orasg_next.equal?(s_t_orasg_next)].inspect}"

s_t_orasg_tern = +"abc"
h_t_orasg_tern = {}
o_t_orasg_tern = OA.new
w_t_orasg_tern = y_t_orasg_tern(s_t_orasg_tern) { |t|
  t.upcase! ? (@x ||= t) : +"zz"
}
w_t_orasg_tern << "9"
puts "top orasg_tern: #{[s_t_orasg_tern, w_t_orasg_tern.equal?(s_t_orasg_tern)].inspect}"

s_t_orasg_tern_next = +"abc"
h_t_orasg_tern_next = {}
o_t_orasg_tern_next = OA.new
w_t_orasg_tern_next = y_t_orasg_tern_next(s_t_orasg_tern_next) { |t|
  t.upcase! ? (next (@x ||= t)) : +"zz"
}
w_t_orasg_tern_next << "9"
puts "top orasg_tern_next: #{[s_t_orasg_tern_next, w_t_orasg_tern_next.equal?(s_t_orasg_tern_next)].inspect}"

class KW
  def initialize
    @x = nil
    @y = nil
    @@c = nil
  end
  def ivar_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_ivar_tail(s) { |t|
      @x = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def ivar_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_ivar_next(s) { |t|
      next (@x = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def ivar_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_ivar_tern(s) { |t|
      t.upcase! ? (@x = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def ivar_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_ivar_tern_next(s) { |t|
      t.upcase! ? (next (@x = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def gvar_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_gvar_tail(s) { |t|
      $g = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def gvar_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_gvar_next(s) { |t|
      next ($g = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def gvar_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_gvar_tern(s) { |t|
      t.upcase! ? ($g = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def gvar_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_gvar_tern_next(s) { |t|
      t.upcase! ? (next ($g = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def cvar_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_cvar_tail(s) { |t|
      @@c = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def cvar_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_cvar_next(s) { |t|
      next (@@c = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def cvar_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_cvar_tern(s) { |t|
      t.upcase! ? (@@c = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def cvar_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_cvar_tern_next(s) { |t|
      t.upcase! ? (next (@@c = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def attr_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_attr_tail(s) { |t|
      o.a = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def attr_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_attr_next(s) { |t|
      next (o.a = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def attr_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_attr_tern(s) { |t|
      t.upcase! ? (o.a = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def attr_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_attr_tern_next(s) { |t|
      t.upcase! ? (next (o.a = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def hash_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_hash_tail(s) { |t|
      h[:k] = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def hash_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_hash_next(s) { |t|
      next (h[:k] = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def hash_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_hash_tern(s) { |t|
      t.upcase! ? (h[:k] = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def hash_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_hash_tern_next(s) { |t|
      t.upcase! ? (next (h[:k] = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def chain_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_chain_tail(s) { |t|
      x = @y = t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def chain_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_chain_next(s) { |t|
      next (x = @y = t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def chain_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_chain_tern(s) { |t|
      t.upcase! ? (x = @y = t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def chain_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_chain_tern_next(s) { |t|
      t.upcase! ? (next (x = @y = t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def orasg_tail
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_orasg_tail(s) { |t|
      @x ||= t
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def orasg_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_orasg_next(s) { |t|
      next (@x ||= t) if t.upcase!
      +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def orasg_tern
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_orasg_tern(s) { |t|
      t.upcase! ? (@x ||= t) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
  def orasg_tern_next
    h = {}
    o = OA.new
    s = +"abc"
    w = y_m_orasg_tern_next(s) { |t|
      t.upcase! ? (next (@x ||= t)) : +"zz"
    }
    w << "9"
    [s, w.equal?(s)]
  end
end
puts "method ivar_tail: #{KW.new.ivar_tail.inspect}"
puts "method ivar_next: #{KW.new.ivar_next.inspect}"
puts "method ivar_tern: #{KW.new.ivar_tern.inspect}"
puts "method ivar_tern_next: #{KW.new.ivar_tern_next.inspect}"
puts "method gvar_tail: #{KW.new.gvar_tail.inspect}"
puts "method gvar_next: #{KW.new.gvar_next.inspect}"
puts "method gvar_tern: #{KW.new.gvar_tern.inspect}"
puts "method gvar_tern_next: #{KW.new.gvar_tern_next.inspect}"
puts "method cvar_tail: #{KW.new.cvar_tail.inspect}"
puts "method cvar_next: #{KW.new.cvar_next.inspect}"
puts "method cvar_tern: #{KW.new.cvar_tern.inspect}"
puts "method cvar_tern_next: #{KW.new.cvar_tern_next.inspect}"
puts "method attr_tail: #{KW.new.attr_tail.inspect}"
puts "method attr_next: #{KW.new.attr_next.inspect}"
puts "method attr_tern: #{KW.new.attr_tern.inspect}"
puts "method attr_tern_next: #{KW.new.attr_tern_next.inspect}"
puts "method hash_tail: #{KW.new.hash_tail.inspect}"
puts "method hash_next: #{KW.new.hash_next.inspect}"
puts "method hash_tern: #{KW.new.hash_tern.inspect}"
puts "method hash_tern_next: #{KW.new.hash_tern_next.inspect}"
puts "method chain_tail: #{KW.new.chain_tail.inspect}"
puts "method chain_next: #{KW.new.chain_next.inspect}"
puts "method chain_tern: #{KW.new.chain_tern.inspect}"
puts "method chain_tern_next: #{KW.new.chain_tern_next.inspect}"
puts "method orasg_tail: #{KW.new.orasg_tail.inspect}"
puts "method orasg_next: #{KW.new.orasg_next.inspect}"
puts "method orasg_tern: #{KW.new.orasg_tern.inspect}"
puts "method orasg_tern_next: #{KW.new.orasg_tern_next.inspect}"

u = nil
s_begin_next = +"abc"
w_begin_next = y_begin_next(s_begin_next) { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  end
}
w_begin_next << "9"
puts "begin_next: #{[s_begin_next, w_begin_next.equal?(s_begin_next)].inspect}"

u = nil
s_begin_next_stmt = +"abc"
w_begin_next_stmt = y_begin_next_stmt(s_begin_next_stmt) { |t|
  begin
    next t if t.upcase!
    +"zz"
  end
}
w_begin_next_stmt << "9"
puts "begin_next_stmt: #{[s_begin_next_stmt, w_begin_next_stmt.equal?(s_begin_next_stmt)].inspect}"

u = nil
s_begin_ensure = +"abc"
w_begin_ensure = y_begin_ensure(s_begin_ensure) { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  ensure
    nil
  end
}
w_begin_ensure << "9"
puts "begin_ensure: #{[s_begin_ensure, w_begin_ensure.equal?(s_begin_ensure)].inspect}"

u = nil
s_begin_rescue_body = +"abc"
w_begin_rescue_body = y_begin_rescue_body(s_begin_rescue_body) { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  rescue
    +"yy"
  end
}
w_begin_rescue_body << "9"
puts "begin_rescue_body: #{[s_begin_rescue_body, w_begin_rescue_body.equal?(s_begin_rescue_body)].inspect}"

u = nil
s_begin_rescue_arm = +"abc"
w_begin_rescue_arm = y_begin_rescue_arm(s_begin_rescue_arm) { |t|
  begin
    raise "x"
  rescue
    t.upcase! ? (next t) : +"zz"
  end
}
w_begin_rescue_arm << "9"
puts "begin_rescue_arm: #{[s_begin_rescue_arm, w_begin_rescue_arm.equal?(s_begin_rescue_arm)].inspect}"

u = nil
s_begin_else = +"abc"
w_begin_else = y_begin_else(s_begin_else) { |t|
  begin
    t.size
  rescue
    +"yy"
  else
    t.upcase! ? (next t) : +"zz"
  end
}
w_begin_else << "9"
puts "begin_else: #{[s_begin_else, w_begin_else.equal?(s_begin_else)].inspect}"

u = nil
s_begin_nested = +"abc"
w_begin_nested = y_begin_nested(s_begin_nested) { |t|
  begin
    begin
      t.upcase! ? (next t) : +"zz"
    end
  end
}
w_begin_nested << "9"
puts "begin_nested: #{[s_begin_nested, w_begin_nested.equal?(s_begin_nested)].inspect}"

u = nil
s_begin_assigned = +"abc"
w_begin_assigned = y_begin_assigned(s_begin_assigned) { |t|
  x = begin
    t.upcase! ? (next t) : +"zz"
  end
  x
}
w_begin_assigned << "9"
puts "begin_assigned: #{[s_begin_assigned, w_begin_assigned.equal?(s_begin_assigned)].inspect}"

u = nil
s_begin_unless = +"abc"
w_begin_unless = y_begin_unless(s_begin_unless) { |t|
  begin
    unless t.upcase!
      +"zz"
    else
      next t
    end
  end
}
w_begin_unless << "9"
puts "begin_unless: #{[s_begin_unless, w_begin_unless.equal?(s_begin_unless)].inspect}"

u = nil
s_begin_case = +"abc"
w_begin_case = y_begin_case(s_begin_case) { |t|
  begin
    case t.upcase!
    when nil then +"zz"
    else next t
    end
  end
}
w_begin_case << "9"
puts "begin_case: #{[s_begin_case, w_begin_case.equal?(s_begin_case)].inspect}"

u = nil
s_or_write = +"abc"
w_or_write = y_or_write(s_or_write) { |t|
  u ||= t
}
w_or_write << "9"
puts "or_write: #{[s_or_write, w_or_write.equal?(s_or_write)].inspect}"

u = nil
s_and_write = +"abc"
w_and_write = y_and_write(s_and_write) { |t|
  u = +"x"
  u &&= t
}
w_and_write << "9"
puts "and_write: #{[s_and_write, w_and_write.equal?(s_and_write)].inspect}"

s_pb = +"abc"
pb = proc { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  end
}
w_pb = pb.call(s_pb)
w_pb << "9"
puts "proc begin: #{[s_pb, w_pb.equal?(s_pb)].inspect}"

s_pe = +"abc"
pe = lambda { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  ensure
    nil
  end
}
w_pe = pe.call(s_pe)
w_pe << "9"
puts "lambda begin ensure: #{[s_pe, w_pe.equal?(s_pe)].inspect}"

s_tb = +"abc"
w_tb = s_tb.then { |t|
  begin
    t.upcase! ? (next t) : +"zz"
  rescue
    +"yy"
  end
}
w_tb << "9"
puts "then begin: #{[s_tb, w_tb.equal?(s_tb)].inspect}"

u = nil
s_bx_read = +"abc"
w_bx_read = 5
w_bx_read = y_bx_read(s_bx_read) { |t|
  t
}
w_bx_read << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_read: #{[s_bx_read, w_bx_read.equal?(s_bx_read), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_read = +"abc"
w_pbx_read = 5
pr_bx_read = proc { |t|
  t
}
w_pbx_read = pr_bx_read.call(s_pbx_read)
w_pbx_read << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_read: #{[s_pbx_read, w_pbx_read.equal?(s_pbx_read), [u, @x, $g]].inspect}"

u = nil
s_bx_local_write = +"abc"
w_bx_local_write = 5
w_bx_local_write = y_bx_local_write(s_bx_local_write) { |t|
  u = t
}
w_bx_local_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_local_write: #{[s_bx_local_write, w_bx_local_write.equal?(s_bx_local_write), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_local_write = +"abc"
w_pbx_local_write = 5
pr_bx_local_write = proc { |t|
  u = t
}
w_pbx_local_write = pr_bx_local_write.call(s_pbx_local_write)
w_pbx_local_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_local_write: #{[s_pbx_local_write, w_pbx_local_write.equal?(s_pbx_local_write), [u, @x, $g]].inspect}"

u = nil
s_bx_ivar_write = +"abc"
w_bx_ivar_write = 5
w_bx_ivar_write = y_bx_ivar_write(s_bx_ivar_write) { |t|
  @x = t
}
w_bx_ivar_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_ivar_write: #{[s_bx_ivar_write, w_bx_ivar_write.equal?(s_bx_ivar_write), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_ivar_write = +"abc"
w_pbx_ivar_write = 5
pr_bx_ivar_write = proc { |t|
  @x = t
}
w_pbx_ivar_write = pr_bx_ivar_write.call(s_pbx_ivar_write)
w_pbx_ivar_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_ivar_write: #{[s_pbx_ivar_write, w_pbx_ivar_write.equal?(s_pbx_ivar_write), [u, @x, $g]].inspect}"

u = nil
s_bx_gvar_write = +"abc"
w_bx_gvar_write = 5
w_bx_gvar_write = y_bx_gvar_write(s_bx_gvar_write) { |t|
  $g = t
}
w_bx_gvar_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_gvar_write: #{[s_bx_gvar_write, w_bx_gvar_write.equal?(s_bx_gvar_write), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_gvar_write = +"abc"
w_pbx_gvar_write = 5
pr_bx_gvar_write = proc { |t|
  $g = t
}
w_pbx_gvar_write = pr_bx_gvar_write.call(s_pbx_gvar_write)
w_pbx_gvar_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_gvar_write: #{[s_pbx_gvar_write, w_pbx_gvar_write.equal?(s_pbx_gvar_write), [u, @x, $g]].inspect}"

u = nil
s_bx_next_write = +"abc"
w_bx_next_write = 5
w_bx_next_write = y_bx_next_write(s_bx_next_write) { |t|
  next (u = t) if t.upcase!
  +"zz"
}
w_bx_next_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_next_write: #{[s_bx_next_write, w_bx_next_write.equal?(s_bx_next_write), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_next_write = +"abc"
w_pbx_next_write = 5
pr_bx_next_write = proc { |t|
  next (u = t) if t.upcase!
  +"zz"
}
w_pbx_next_write = pr_bx_next_write.call(s_pbx_next_write)
w_pbx_next_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_next_write: #{[s_pbx_next_write, w_pbx_next_write.equal?(s_pbx_next_write), [u, @x, $g]].inspect}"

u = nil
s_bx_tern_write = +"abc"
w_bx_tern_write = 5
w_bx_tern_write = y_bx_tern_write(s_bx_tern_write) { |t|
  t.upcase! ? (u = t) : +"zz"
}
w_bx_tern_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "bx_tern_write: #{[s_bx_tern_write, w_bx_tern_write.equal?(s_bx_tern_write), [u, @x, $g]].inspect}"

u = nil
@x = nil
$g = nil
s_pbx_tern_write = +"abc"
w_pbx_tern_write = 5
pr_bx_tern_write = proc { |t|
  t.upcase! ? (u = t) : +"zz"
}
w_pbx_tern_write = pr_bx_tern_write.call(s_pbx_tern_write)
w_pbx_tern_write << "9"
[u, @x, $g].each { |z| z << "!" if z }
puts "proc bx_tern_write: #{[s_pbx_tern_write, w_pbx_tern_write.equal?(s_pbx_tern_write), [u, @x, $g]].inspect}"

u = nil
s_c5 = +"abc"
w_c5 = y_c5(s_c5) { |t| u = t }
u << "u"
w_c5 << "w"
puts "shared local write: #{[s_c5, u, w_c5].inspect}"

# A variable's `||=`, `&&=` and `op=` (a local's, an instance, global or class
# variable's) as the block's value, and a Float or Range `next`.
def y1(x) = yield(x)
$opq = nil
$opr = 3
class OpK
  @@c = nil
  @@d = 4
  def initialize; @z = nil; @n = 2; @s = nil; end
  def run
    r = []
    r << y1(5) { |t| @z ||= t }
    r << y1(5) { |t| @n &&= t }
    r << y1(5) { |t| @n += t }
    r << y1(5) { |t| @n -= 1 }
    r << y1(5) { |t| $opq ||= t }
    r << y1(5) { |t| $opr &&= t }
    r << y1(6) { |t| $opr += t }
    r << y1(5) { |t| @@c ||= t }
    r << y1(5) { |t| @@d &&= t }
    r << y1(5) { |t| @@d *= t }
    r << y1("s") { |t| @s ||= t }
    r << y1("s") { |t| @s &&= t }
    r << y1("s") { |t| @s += t }
    r
  end
end
p OpK.new.run
x = 1
w = y1(5) { |t| x += t }
p w, x
w = y1(5) { |t| x -= t }
p w
w = y1(5) { |t| x *= 2 }
p w
w = y1(5) { |t| @optop ||= t }
p w
w = y1(5) { |t| $optop2 ||= t }
p w
w = y1(5) { |t| $optop2 &&= t + 1 }
p w
p(y1(0.0) { |v| next 0.25 if v == 0.0; v / 4 })
p(y1(1.5) { |v| next 0.25 if v == 0.0; v / 4 })
p(y1(0) { |v| next (1..3) if v == 0; (4..5) })
p(y1(1) { |v| next (1..3) if v == 0; (4..5) })
p(y1(0) { |v| next 2.5r if v == 0; 1r })
p(y1(0) { |v| next Time.at(0).utc.year if v == 0; 5 })
p(y1(0) { |v| next [1] if v == 0; [2, 3] })
p(y1(0) { |v| next 1 if v == 0; nil })
p(y1(0) { |v| next 1.5 if v == 0; nil })
p(y1(0) { |v| next Complex(1, 2) if v == 0; Complex(0, 1) })
