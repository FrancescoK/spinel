module A; Pt = Struct.new(:x); end; module B; Pt = Struct.new(:y); end; p A::Pt.members, B::Pt.members
