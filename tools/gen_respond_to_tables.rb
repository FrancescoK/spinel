#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Generates lib/spinel_rt_responds_generated.h: the respond_to? reflection
# arrays for the five classes whose bop_rows[] coverage is complete enough
# to generate from (see docs/superpowers/specs/2026-10-12-generate-respond-
# to-tables-design.md for why these five and not the other six classes
# sp_poly_responds_builtin branches on).
#
#   ruby tools/gen_respond_to_tables.rb > lib/spinel_rt_responds_generated.h
#
require_relative "builtin_row_gen"

module GenRespondToTables
  ROOT = File.expand_path("..", __dir__)
  # bop_rows families this generator replaces the hand-written array for.
  # Proc is deliberately absent: its hand-written procm[] already covers
  # every bop_rows row that isn't already in the universal uni[] list (see
  # the spec), so there is nothing to generate -- only to keep checking.
  FAMILIES = %w[Array Hash String Integer Float].freeze

  # [family, name] pairs BuiltinRowGen.method_list reports that are not
  # actually true: BuiltinRowGen::FAMILIES attributes every TY_POLY row to
  # String (and Symbol), because most TY_POLY rows genuinely are String's
  # boxed face (capitalize, downcase, dump, swapcase, undump, upcase). The
  # 2-argument "pack" row under TY_POLY is Array#pack's buffer-argument
  # dispatch variant, not a String method -- CRuby: "".respond_to?(:pack)
  # is false. BuiltinRowGen's own use (probing call shapes on real
  # receivers) never hits this, since it never builds a String sample to
  # call "pack" on; this generator asks "is this really true of the
  # class," where the misattribution matters.
  FALSE_POSITIVE = { "String" => %w[pack] }.freeze

  # The shared manual arrays sp_poly_responds_builtin already ORs in
  # alongside each class's generated array: uni[] unconditionally for
  # every class (checked once, before any class dispatch), enumm[]
  # additionally for Array and Hash, numm[] additionally for Integer and
  # Float. A name already covered by one of these must not be duplicated
  # into the generated array -- the hand-written tables this replaces
  # never did, and generating it anyway would only make the output bigger
  # without changing any respond_to? answer.
  SHARED_ARRAYS = {
    "Array" => %w[uni enumm], "Hash" => %w[uni enumm], "String" => %w[uni],
    "Integer" => %w[uni numm], "Float" => %w[uni numm],
  }.freeze

  class GenError < StandardError; end

  module_function

  # rt_header_text: lib/spinel_rt.h's current text, read once by the
  # caller, so the Proc self-check and the shared-array dedup (below) can
  # look inside it without a second file read.
  def generate(rt_header_text)
    check_proc_coverage(rt_header_text)
    shared = SHARED_ARRAYS.to_h { |family, arrays|
      [family, arrays.flat_map { |a| array_literal_names(rt_header_text, a) }]
    }
    names_by_family = FAMILIES.to_h { |f| [f, []] }
    BuiltinRowGen.method_list.each do |family, name|
      next unless names_by_family.key?(family)
      next if BuiltinRowGen::INTERNAL_NAME.match?(name)
      next if FALSE_POSITIVE.fetch(family, []).include?(name)
      next if shared.fetch(family).include?(name)
      names_by_family[family] << name
    end
    names_by_family.each_value { |names| names.sort!.uniq! }
    render(names_by_family)
  end

  # Every TY_PROC row bop_rows registers, minus the ones the universal
  # uni[] array already covers, must already be a literal in procm[]'s
  # text -- otherwise bop_rows grew a Proc method procm[] doesn't know
  # about, and a human needs to add it by hand (see the spec's Scope
  # section: Proc is verified-complete, not generated).
  def check_proc_coverage(rt_header_text)
    uni = array_literal_names(rt_header_text, "uni")
    procm = array_literal_names(rt_header_text, "procm")
    proc_rows = BuiltinRowGen.method_list
                             .select { |family, _| family == "Proc" }
                             .map(&:last)
                             .reject { |name| BuiltinRowGen::INTERNAL_NAME.match?(name) }
                             .uniq
    missing = proc_rows - uni - procm
    return if missing.empty?

    raise GenError,
          "bop_rows now has Proc method(s) procm[]/uni[] in lib/spinel_rt.h " \
          "don't cover: #{missing.join(", ")}. Add them to procm[] by hand " \
          "(Proc is verified-complete, not generated -- see the spec)."
  end

  # The string literals inside `static const char *const <array_name>[] =
  # { ... };` in lib/spinel_rt.h's text, by direct string scanning (the
  # same "read the hand-kept array as text" approach builtin_row_gen.rb
  # itself already uses on builtin_ops.c).
  def array_literal_names(text, array_name)
    start = text.index(/static const char \*const #{array_name}\[\] = \{/) or
      raise GenError, "no #{array_name}[] array found in lib/spinel_rt.h"
    stop = text.index("};", start) or
      raise GenError, "#{array_name}[] array in lib/spinel_rt.h has no closing };"
    text[start...stop].scan(/"((?:[^"\\]|\\.)*)"/).flatten.map { |s| s.gsub(/\\(.)/, '\1') }
  end

  def render(names_by_family)
    out = +"/* Generated by tools/gen_respond_to_tables.rb from src/builtin_ops.c's\n" \
          " * bop_rows[]. Do not edit by hand -- edit bop_rows[] and regenerate.\n" \
          " * See docs/superpowers/specs/2026-10-12-generate-respond-to-tables-design.md\n" \
          " */\n"
    FAMILIES.each do |family|
      const = "sp_gen_responds_#{family.downcase}"
      out << "static const char *const #{const}[] = {\n"
      names_by_family.fetch(family).each { |n| out << "  #{n.inspect},\n" }
      out << "  NULL\n};\n"
    end
    out
  end
end

if $PROGRAM_NAME == __FILE__
  rt_header = File.read(File.join(GenRespondToTables::ROOT, "lib/spinel_rt.h"))
  puts GenRespondToTables.generate(rt_header)
end
