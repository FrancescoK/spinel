# Regression for collision-renamed class seeds (sibling of #1417). When two
# modules define the same leaf class name, qualify_colliding_classes renames
# the classes to the `Mod__Leaf` (double-underscore) form -- but the extractor
# emits their seeds under the single-underscore path join (`Red_Base`), so no
# exact-name form matched and the seeds for exactly the collision-prone
# classes were silently dropped. (On a Rails-shaped tree that set is
# ActiveRecord::Base / ActionController::Base / ActionMailer::Base -- the
# hottest classes in the program.)
#
# `Red::Base#@rtag` is declared `String?` but only ever assigned nil, so
# inference alone leaves it poly; only an applied seed pins the field to
# `const char *` (the #1417 detection shape).
#
# `Blue::Base#btag` is declared `(Integer | String)` -- the extractor emits
# the bare `poly` tag for a heterogeneous union (#1255). The body alone would
# infer int, so a `sp_RbVal`-returning btag proves the poly token was parsed
# and pinned rather than silently dropped.
# spinel: rbs-seed-check
module Red
  class Base
    class Inner
      def initialize
        @itag = nil
      end
      def itag
        @itag
      end
    end
    def initialize
      @rtag = nil
    end
    def rtag
      @rtag
    end
  end
end

module Blue
  class Base
    def btag
      42
    end
  end
end

p Red::Base.new.rtag.nil?
p Blue::Base.new.btag
p Red::Base::Inner.new.itag.nil?
