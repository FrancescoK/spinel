module M; class String::Helper; def w = :s; end; class Helper; def w = :m; end; end; p String::Helper.new.w, M::Helper.new.w
