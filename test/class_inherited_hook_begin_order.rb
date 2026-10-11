# Code in `BEGIN` blocks runs before the rest of the file, in the order it is
# written, wherever the block sits. A class created there before its
# superclass's inherited hook is defined fires nothing, even when the hook
# comes in the same block or is written earlier in the file.

BEGIN {
  class Base; end
  class Early < Base; end
  class Base
    def self.inherited(k) = puts("Base got #{k}")
  end
  class Late < Base; end
}
class After < Base; end

class Base2
  def self.inherited(k) = puts("Base2 got #{k}")
end
class After2 < Base2; end
BEGIN {
  class Base2; end
  class Early2 < Base2; end
}

BEGIN { class Base3; end; class Early3 < Base3; end }
BEGIN { class Base3; def self.inherited(k) = puts("Base3 got #{k}"); end }
BEGIN { class Late3 < Base3; end }
