# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# spinel: not-cruby -- the default Integer overflow policy raises RangeError.
# Integer arithmetic that overflows sp_int (int64) raises
# RangeError rather than silently wrapping. spinel uses
# `__builtin_add_overflow` / `_sub_overflow` / `_mul_overflow`
# at the codegen-emit step for binary `+ - *` on int operands;
# the helpers (defined as statement-expression macros in
# sp_runtime.h) raise on overflow and otherwise reduce to the
# bare arithmetic op. BIGINT.md option β.
#
# Non-overflowing arithmetic must still produce the expected
# native-int result, and `rescue` must catch the raise so the
# program can continue.

# Sanity: non-overflowing arithmetic still works.
puts 100 + 200
puts 1000 - 500
puts 6 * 7

# Each of the three operators raises on overflow.
[:plus, :minus, :mul].each do |op|
  begin
    huge = 9_223_372_036_854_775_000
    case op
    when :plus
      x = huge + 9_223_372_036_854_775_000
    when :minus
      x = -huge - 9_223_372_036_854_775_000
    when :mul
      x = huge * 1000
    end
    puts "no raise from #{op}: #{x}"
  rescue RangeError => e
    puts "#{op}: caught #{e.message}"
  end
end

def sum_overflow
  yield
rescue RangeError => e
  p [e.class, e.message]
end
sum_overflow { [2**62].sum(2**62) }
sum_overflow { [2**62, 2**62].sum(2**62) }
sum_overflow { [2**62, 2**62].sum }
sum_overflow { [2**62].sum(2**62) { |x| x } }
sum_overflow { [2**62, 2**62].sum { |x| x } }
sum_overflow { [2**62, 2**62, -(2**62)].sum }
