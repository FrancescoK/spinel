# An inherited hook fires for the subclasses of the class that has it, told
# by the full name: another class of the same leaf name, in another
# namespace, has none, and its subclasses run no hook.
module Syn
  class Base
    class << self
      attr_accessor :features

      def inherited(sub)
        super
        (@seen ||= []) << sub.name
        sub.features = (features || {}).merge(sub.name => true)
      end

      def seen = @seen
    end
  end

  class V1 < Base; end
  class V2 < Syn::Base; end
end

module Expr
  class Base
    def x = 1
  end

  class Lit < Expr::Base; end
  class Esc < Base; end
  class Deep < Esc; end
end

p Expr::Lit.new.x, Expr::Esc.new.x, Expr::Deep.new.x
p Syn::Base.seen
p Syn::V1.features
p Expr::Lit.respond_to?(:features)

# inside a class whose ancestors may supply the superclass's name, the
# leaf names decide, as before: the hook still fires
class Holder < Expr::Base
  class V3 < Syn::Base; end
end
p Syn::Base.seen.size
