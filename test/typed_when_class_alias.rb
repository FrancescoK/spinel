# A constant aliasing a class (Rec = Point) matches an instance of it in
# `when` and `in` on a typed object, as it does on a boxed one; a name that
# is itself a class keeps naming that class.
module Tagged; end
class Base; end
class Point < Base
  include Tagged
end
class Line; end
Rec = Point
Obj = Object
Up = Base
Tg = Tagged
module Legacy
  Point = Line
end
x = Point.new
p(case x; when Rec then :rec; else :no; end)
p(case x; in Rec then :rec; else :no; end)
p(case Line.new; when Rec then :rec; else :no; end)
p(case x; when Obj then :obj; else :no; end)
p(case x; in Obj then :obj; else :no; end)
p(case [x, 1][0]; when Rec then :rec; else :no; end)
p(case x; when Up then :up; else :no; end)
p(case x; when Tg then :tagged; else :no; end)
p(case x; when Point then :point; else :no; end)
