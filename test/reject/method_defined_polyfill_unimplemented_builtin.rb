# spinel: reject-subclass: String#unicode_normalize is not supported
# CRuby's String has unicode_normalize, so method_defined? is true and the
# polyfill's def does not run: the call reaches the builtin, which Spinel
# does not implement, and is refused rather than running the polyfill.
class String
  unless method_defined?(:unicode_normalize)
    def unicode_normalize(_form = :nfc) = self
  end
end
p "x".unicode_normalize
