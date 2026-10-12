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
