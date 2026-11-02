class String::Helper; def w = :sh; end; module M; class Helper; def w = :mh; end; end; p(begin; Helper.new.w; rescue NameError; :name_error; end)
