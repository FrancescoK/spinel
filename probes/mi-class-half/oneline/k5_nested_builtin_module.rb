module M; module Comparable; def hi = :m; end; end; class P; include Comparable; end; p P.new.respond_to?(:hi)
