# A `[]=` on a poly receiver that may hold a Struct gets one dispatch arm per Struct
# class it may hold, and the arm binds the receiver as "((sp_<Class> *)_t0.v.p)" in a
# fixed 32-byte slot: a class name of 15 characters or more cut the text short without
# a word and the C did not build (#7604).
WidgetMeasurement = Struct.new(:width, :height)
Widget = Struct.new(:width, :height)
AVeryLongStructNameForAPointWithManyLetters = Struct.new(:x, :y)

rows = [WidgetMeasurement.new(1, 2), { 0 => 0 }]
rows.each { |row| row[0] = 7 }
p rows[0].width
p rows[1]

short = [Widget.new(1, 2), { 0 => 0 }]
short.each { |row| row[1] = 8 }
p short[0].height
p short[1]

long = [AVeryLongStructNameForAPointWithManyLetters.new(3, 4), { 0 => 0 }]
long.each { |row| row[0] = 9 }
p long[0].x
p long[1]

mixed = [WidgetMeasurement.new(1, 2), AVeryLongStructNameForAPointWithManyLetters.new(5, 6)]
mixed.each { |row| row[1] = 0 }
p mixed.map(&:to_a)
