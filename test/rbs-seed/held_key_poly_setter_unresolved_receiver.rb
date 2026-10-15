# spinel: rbs-seed-run
# A key that is a boxed value's to_s, given to a setter on a receiver the
# compiler cannot resolve (`out` is bound nowhere, so the call never runs:
# the params are empty) beside a value that runs a program method, is
# hoisted into a String temp ahead of the call. The poly dispatch's arm for
# a signature-declared untyped key then asked the key's route again, which
# read the temp as its handle under --share-strings: the C passed a
# `const char *` where an `sp_String *` was wanted.
module HkNokogiri
  class Attr
    def to_s
      ""
    end
  end

  class Element
    def []=(_key, _value)
      _value
    end
  end
end

module HkBuilder
  def self.from_json(params)
    params.each do |k, v|
      out[k.to_s] = HkBuilder.normalize_json(v)
    end
  end

  def self.normalize_json(value)
    if value.is_a?(Hash)
      out = {}
      value.each do |k, v|
        out[k.to_s] = HkBuilder.normalize_json(v)
      end
      out = []
    end
  end
end

req = ARGV.empty? ? {} : []
p HkBuilder.from_json(req)
