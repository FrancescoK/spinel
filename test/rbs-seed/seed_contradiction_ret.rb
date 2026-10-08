# A contradicted RETURN-type seed. A seed is trusted, so the emitted function
# carries the declared C type and the body's value is placed in it rather than
# converted -- a String body under a `-> Hash[...]` seed returns a char* from a
# function typed sp_SymPolyHash *. Only the C compiler used to report that, in
# its voice and against generated code (#4005); spinel refuses it here, naming
# the method, the declared type and the returned one.
# spinel: rbs-seed-contradicted-return
class C
  def f
    "not a hash"
  end
end

puts C.new.f.inspect
