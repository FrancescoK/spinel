# Regression for #3203: a return seed on a class method that a subclass
# overrides pinned the base decl's C repr to the concrete class pointer
# (`sp_OfrBase *`), while a call site reached through poly dispatch kept
# the family (boxed) view and unboxed the result (`.v.p`) -- the
# generated C failed to compile:
#
#   return (sp_OfrBase *)(sp_OfrBase_s_instantiate(lv_conditions)).v.p;
#
# Return seeds now skip override-family methods, keeping the family on
# its inferred (consistent) repr -- the same never-makes-inference-worse
# rule the seed path applies to layout conflicts. Params still seed.
# All three ingredients are load-bearing: the nilable return seed on
# find_by, the subclass override of instantiate, and the unresolved
# (poly-dispatch) receiver at the call site.
# spinel: rbs-seed-check
class OfrBase
  def self.instantiate(_row)
  end

  def self.find_by(conditions)
    instantiate(conditions)
  end
end

class OfrSub < OfrBase
  def self.instantiate(row)
  end
end

OfrModel.find_by(1)
