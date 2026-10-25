# frozen_string_literal: true
require_relative 'symbol_ids'

class SymbolShape
  def initialize(w, h)
    @w = w
    @h = h
  end

  def area = @w * @h
  def scale(x, y) = SymbolShape.new(@w * x, @h * y)
  def each
    yield @w
    yield @h
  end
  def inspect = "#<SymbolShape #{@w}x#{@h}>"

  private

  def secret = :hidden
end

class SymbolReducer
  def _reduce_1(val, _values) = val.sum
  def _reduce_2(val, _values) = val.max
end

shape = SymbolShape.new(2, 3)
p CextSymbolIds.call0(shape, :area)
p CextSymbolIds.call0(shape, :secret)
p CextSymbolIds.call2(shape, :scale, 10, 100)
p CextSymbolIds.call0(shape, "ar#{"ea"}".to_sym)
p CextSymbolIds.iterate(shape, :each)
p CextSymbolIds.literal(shape)
p CextSymbolIds.name_of(:_reduce_2)
reducer = SymbolReducer.new
[:_reduce_1, :_reduce_2].each do |action|
  p CextSymbolIds.call2(reducer, action, [4, 9, 1], [])
end
p CextSymbolIds.call0([3, 1, 2], :reverse)
p CextSymbolIds.call0({a: 1}, :keys)
p CextSymbolIds.call0("text", :upcase)
begin
  CextSymbolIds.call0(shape, :missing_method)
rescue NoMethodError => e
  p e.class
end
