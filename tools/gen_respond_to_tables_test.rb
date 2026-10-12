#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative "gen_respond_to_tables"

ROOT = File.expand_path("..", __dir__)
RT_HEADER = File.read(File.join(ROOT, "lib/spinel_rt.h"))

checks = 0

# Each of the five target classes' generated array is non-empty and
# NULL-terminated, and contains a name real bop_rows registers for it.
{
  "Array" => "uniq!", "Hash" => "transform_keys!", "String" => "delete_prefix!",
  "Integer" => "digits", "Float" => "next_float",
}.each do |family, must_have|
  out = GenRespondToTables.generate(RT_HEADER)
  const = "sp_gen_responds_#{family.downcase}"
  abort "missing array #{const}" unless out.include?("#{const}[]")
  body = out[/#{const}\[\] = \{(.*?)\};/m, 1] or abort "could not extract #{const}'s body"
  abort "#{const} is empty" if body.strip == "NULL,"
  abort "#{const} is missing \"#{must_have}\"" unless body.include?("\"#{must_have}\"")
  abort "#{const} is not NULL-terminated" unless body.strip.end_with?("NULL,") || body.strip.end_with?("NULL")
  checks += 1
end

# The internal-name filter actually excludes __bivar_get-shaped names:
# BOP_IVAR_LESS rows are attributed to both Integer and String by
# BuiltinRowGen::FAMILIES, so Integer's array must not contain it.
out = GenRespondToTables.generate(RT_HEADER)
integer_body = out[/sp_gen_responds_integer\[\] = \{(.*?)\};/m, 1]
abort "internal name leaked into Integer's array" if integer_body.include?('"__bivar_get"')
checks += 1

# "pack"'s TY_POLY row in bop_rows is Array#pack's 2-arg buffer-argument
# dispatch variant, not a String method -- BuiltinRowGen::FAMILIES
# attributes every TY_POLY row to String (and Symbol) because most TY_POLY
# rows genuinely are String's boxed face (capitalize, downcase, dump,
# swapcase, undump, upcase), but this one isn't. CRuby: "".respond_to?(:pack)
# is false.
out = GenRespondToTables.generate(RT_HEADER)
string_body = out[/sp_gen_responds_string\[\] = \{(.*?)\};/m, 1]
abort "false positive: \"pack\" leaked into String's array (Array#pack's " \
      "buffer-argument TY_POLY row, not a real String method)" if string_body.include?('"pack"')
checks += 1

# Dedup against the shared manual arrays sp_poly_responds_builtin already
# ORs in: uni[] (every class), enumm[] (Array/Hash only), numm[] (Integer/
# Float only). A name already covered there must not also be duplicated
# into the generated array -- the manual tables never did, and the point
# is to shrink the generated output, not just add to it.
out = GenRespondToTables.generate(RT_HEADER)
array_body = out[/sp_gen_responds_array\[\] = \{(.*?)\};/m, 1]
abort "\"each\" (in enumm) was not deduped out of Array's array" if array_body.include?('"each"')
abort "\"clone\" (in uni) was not deduped out of Array's array" if array_body.include?('"clone"')
abort "\"uniq!\" (real Array-only name) was wrongly deduped away" unless array_body.include?('"uniq!"')
integer_body2 = out[/sp_gen_responds_integer\[\] = \{(.*?)\};/m, 1]
abort "\"round\" (in numm) was not deduped out of Integer's array" if integer_body2.include?('"round"')
abort "\"digits\" (real Integer-only name) was wrongly deduped away" unless integer_body2.include?('"digits"')
checks += 1

# The Proc self-check actually fires: stub method_list with a Proc name
# that is in neither procm nor uni, and confirm GenRespondToTables raises.
module BuiltinRowGen
  class << self
    alias_method :real_method_list, :method_list
    def method_list
      real_method_list + [["Proc", "__bogus_method_not_real__"]]
    end
  end
end
begin
  GenRespondToTables.generate(RT_HEADER)
  abort "the Proc self-check did not fire for an uncovered name"
rescue GenRespondToTables::GenError => e
  abort "wrong error message: #{e.message}" unless e.message.include?("__bogus_method_not_real__")
  checks += 1
end

puts "gen_respond_to_tables_test: #{checks} checks passed"
