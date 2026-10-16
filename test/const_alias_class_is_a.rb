# A constant that aliases a class (Money = Support::Money) names that class in
# is_a?, kind_of? and instance_of?. Inside the class body, the bare leaf Money
# reads the outer alias, so the check there tests the class too.
module Shop
  module Support
    class Money
      include Comparable
      attr_reader :cents

      def initialize(cents) = @cents = cents

      def <=>(other)
        return nil unless other.is_a?(Money)
        cents <=> other.cents
      end

      def same_kind?(other) = other.kind_of?(Money)
      def exact?(other) = other.instance_of?(Money)
    end

    class Coupon; end
  end

  Money = Support::Money
  Cash = Support::Money
end

a = Shop::Support::Money.new(100)
b = Shop::Money.new(250)
coupon = Shop::Support::Coupon.new
p a < b
p [b, a].max.cents
p a.same_kind?(b)
p a.exact?(b)
p a.same_kind?(coupon)
p a.exact?(coupon)
p((a <=> coupon))
p b.is_a?(Shop::Money)
p b.instance_of?(Shop::Money)
p b.is_a?(Shop::Cash)
p b.kind_of?(Shop::Cash)
p coupon.is_a?(Shop::Money)
p coupon.is_a?(Shop::Cash)

# A top-level alias of a nested class.
module Billing
  class Invoice; end
  class Receipt; end
end
Invoice = Billing::Invoice
Bill = Billing::Invoice
invoice = Billing::Invoice.new
p invoice.is_a?(Invoice)
p invoice.instance_of?(Bill)
p Billing::Receipt.new.is_a?(Invoice)
