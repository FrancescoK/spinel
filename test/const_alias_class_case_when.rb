# A constant that aliases a class (Money = Support::Money) names that class in
# a case/when branch, alone or in a list. Inside the class body, the bare leaf
# Money reads the outer alias, so the branch there tests the class too. Each
# method sees one class only, so the compiler can choose the branch itself.
module Shop
  module Support
    class Money
      def kind(other)
        case other
        when Money then "money"
        else "other"
        end
      end
    end

    class Coupon
      def kind(other)
        case other
        when Shop::Money then "money"
        else "other"
        end
      end
    end
  end

  Money = Support::Money
  Cash = Support::Money
end

def label(item)
  case item
  when Shop::Money then "same leaf"
  else "miss"
  end
end

def label_other_leaf(item)
  case item
  when Shop::Cash then "other leaf"
  else "miss"
  end
end

def label_any(item)
  case item
  when Integer, Shop::Money then "listed"
  else "miss"
  end
end

def label_coupon(item)
  case item
  when Shop::Money, Shop::Cash then "money"
  else "miss"
  end
end

money = Shop::Money.new
coupon = Shop::Support::Coupon.new
p money.kind(money)
p coupon.kind(coupon)
p label(money)
p label_other_leaf(money)
p label_any(money)
p label_coupon(coupon)
