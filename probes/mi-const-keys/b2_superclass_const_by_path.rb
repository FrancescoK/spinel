class Base2; end
class Sub2 < Base2; def x = 1; end
Base2::LIM = 3
p Sub2::LIM
class Base3; LIM = 7; end
class Sub3 < Base3; end
p Sub3::LIM
