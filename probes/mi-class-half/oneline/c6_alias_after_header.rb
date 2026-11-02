class Foo; def w = :foo; end; class A; def w = :a; end; B = A; A = Foo; p A.new.w, B.new.w
