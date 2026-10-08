# Hash#fetch / #fetch_values / #delete with a BLOCK and a key of a class the
# table cannot hold: the block's parameter is typed as the table's key kind,
# so a key of another class has no slot to arrive in. Spinel refuses at
# compile time and names the case, rather than putting the raw value in the
# typed slot and stopping the generated-C build. The blockless forms -- which
# simply miss, the way CRuby's #hash / #eql? lookup does -- are pinned by
# test/typed_slot_conversion.rb.
# spinel: rbs-seed-check
h = { 1 => 2 }
p h.fetch("a") { |k| k }
