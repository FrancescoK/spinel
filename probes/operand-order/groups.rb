# Sorts the order probe's non-ok cases into mechanism groups.
#   ruby groups.rb GENDIR LABEL [LABEL2 ..]
# A case is first checked for a cause that is not evaluation order (the
# observed answer is a compile error, or an exception CRuby does not raise of
# a kind no order can explain); then its family picks the group. Prints a
# table: group, then the non-ok count under each label, then the families.
gdir, *labels = ARGV
cases = {}
File.foreach(File.join(gdir, "cases.tsv")) do |l|
  id, shape, kind, fam, route, expr = l.chomp.split("\t", 6)
  cases[id.to_i] = { fam: fam.sub(%r{/$}, ""), shape: shape, expr: expr }
end
res = labels.to_h do |lb|
  h = {}
  File.foreach(File.join(gdir, "#{lb}.results.tsv")) { |l| id, st, exp, obs = l.chomp.split("\t", 4); h[id.to_i] = [st, exp.to_s, obs.to_s] }
  [lb, h]
end

GROUPS = [
  ["X1 not order: String#[]= on an expression receiver raises NoMethodError", ->(c, st, e, o) { c[:shape] == "str_aset" && o =~ /NoMethodError/ && e !~ /NoMethodError/ }],
  ["X2 not order: a proc's String answer as a String mutator's receiver does not compile", ->(c, st, e, o) { st == "CERR" }],
  ["X3 not order: a builtin's own check order (FrozenError for IndexError)", ->(c, st, e, o) { e =~ /IndexError/ && o =~ /FrozenError/ }],
  ["X4 not order: a lambda passed through a method's answer as &blk gets a mistyped parameter", ->(c, *) { c[:fam] == "hand/bp_lambda_via_call" }],
  ["G1 a String operand's bytes taken early / receiver read late (handle-hold PR)", ->(c, *) { c[:fam] =~ %r{\A(str_center|str_sub|str_cmp|str_eqq?|str_idx|str_incl|str_mul|str_plus|nested|hash_lit|hash_fetch|str_concat/v1)} }],
  ["G2 block-pass expression evaluated before the arguments", ->(c, *) { c[:fam] =~ %r{\Ablockpass} }],
  ["G3 =~ arm hoists its pattern ahead of the receiver", ->(c, *) { c[:fam] =~ %r{\A(str_match|hand/match_im)} }],
  ["G4 a String mutator's receiver slot read at the call, after an argument rebound it", ->(c, *) { c[:fam] =~ %r{\A(str_app|str_concat|str_insert|str_aset)/v0} }],
  ["G5 a user object receiver read after an argument rebound it", ->(c, *) { c[:fam] =~ %r{\Aurecv} }],
  ["G6 a[i] op= v answers the slot read again after v rebound a", ->(c, *) { c[:fam] =~ %r{\Aarr_opasgn} }],
  ["G7 an operand the callee ignores is not evaluated (fetch default, nil block-pass)", ->(c, *) { c[:fam] =~ %r{\A(arr_fetch|hand/bp_nil)} }],
  ["G8 an arm that consumes its arguments one C statement at a time (push)", ->(c, *) { c[:fam] =~ %r{\A(arr_push|arr_unshift)} }],
  ["G9 a splat expanded after a later argument ran", ->(c, *) { c[:fam] =~ %r{\A(splat|arr_lit_splat)} }],
  ["G10 an interpolation part held as its bytes (Matz item 2, second shape)", ->(c, *) { c[:fam] =~ %r{\Ahand/matz2} }],
  ["G11 an index assignment's value read before its receiver ran (`m[i] = @s`)", ->(c, *) { c[:fam] =~ %r{\Astr_aset/v2} }],
  ["G12 other", ->(*) { true }],
]

tab = Hash.new { |h, k| h[k] = { n: Hash.new(0), fams: Hash.new(0) } }
cases.each do |id, c|
  labels.each do |lb|
    st, e, o = res[lb][id]
    next if st == "ok" || st.nil?
    g = GROUPS.find { |_, f| f.(c, st, e, o) }[0]
    tab[g][:n][lb] += 1
    tab[g][:fams][c[:fam]] += 1 if lb == labels[0]
  end
end
puts ["group", *labels].join("\t")
tot = Hash.new(0)
GROUPS.each do |g, _|
  next unless tab.key?(g)
  labels.each { |lb| tot[lb] += tab[g][:n][lb] }
  puts [g, *labels.map { |lb| tab[g][:n][lb] }].join("\t")
  puts "    " + tab[g][:fams].sort.map { |f, n| "#{f} #{n}" }.join(", ") unless tab[g][:fams].empty?
end
puts ["TOTAL non-ok of #{cases.size}", *labels.map { |lb| tot[lb] }].join("\t")
