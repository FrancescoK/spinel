# A constant set from an Integer Array element that may be nil holds it
# boxed; a constant that is only its name (`TEXT = Theme::TEXT`) holds the
# same box, and its readers unbox it (#8575).
module Chips
  class VIC
    PALETTE = [0x000000, 0xffffff, 0x924a40, 0x84c5cc].freeze
    attr_accessor :palette
  end
end

module Theme
  TEXT = Chips::VIC::PALETTE[3]
end

class FilterView
  TEXT = Theme::TEXT
  AGAIN = TEXT

  def initialize(paint) = @paint = paint
  def draw = @paint.text(1, TEXT)
  def again = @paint.text(2, AGAIN)
end

class Paint
  def text(x, color) = puts("#{x} #{color.to_s(16)}")
end

vic = Chips::VIC.new
vic.palette = Chips::VIC::PALETTE
p vic.palette.size
FilterView.new(Paint.new).draw
FilterView.new(Paint.new).again
p Theme::TEXT
p FilterView::TEXT + 1
