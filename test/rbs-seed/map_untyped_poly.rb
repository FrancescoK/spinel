# Regression (#1602): mapping an untyped block result into a poly array must
# not emit sp_box_int(sp_box_nil()) (an sp_int slot fed an already-boxed
# value). `@model` is an unassigned (untyped) ivar, so `@model.build(row)` is
# untyped; the map collects it into a poly array and must box it correctly
# (yield nil), not wrap it in sp_box_int. `rows` is empty, so the body never
# runs -- the map loop is still emitted, exercising the boxing -- and the
# observable result is the length (0).
#
# (Originally fed `rows` from an RBS-only adapter stubbed to empty via the
# unresolved-call silent-nil; an unresolved call now raises NoMethodError, so
# `rows` is a real empty array whose map result is a poly array -- same codegen
# check, no silent stub.)
# spinel: rbs-seed-check
def build_all
  rows = []
  rows.map { |row| @model.build(row) }
end

puts build_all.length
