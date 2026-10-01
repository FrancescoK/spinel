# Array#zip with a block and other than one operand (two, three, a splat,
# none; a Range receiver too) yields each tuple and answers nil.
r = []; [1, 2, 3].zip([4, 5, 6], [7, 8, 9]) { |c| r << c }
p r
r2 = []; [1, 2].zip([3, 4]) { |a, b| r2 << a + b }
p r2
r3 = []; p([1, 2].zip([3], ["a", "b"]) { |x| r3 << x })
p r3
r4 = []; [1, 2].zip([3, 4], [5, 6]) { |a, b, c| r4 << a + b + c }
p r4
r5 = []; [1, 2].zip { |x| r5 << x }
p r5
xs = [[10, 20], [30, 40]]
r6 = []; [1, 2].zip(*xs) { |t| r6 << t }
p r6
r7 = []; (1..2).zip([5, 6], [7, 8]) { |t| r7 << t.sum }
p r7
