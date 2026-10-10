# spinel: rbs-seed-check
# A String a value block of another class mutates through a call by name
# (body["a"]["b"]["c"] = "") does not demand handles of an ivar an --rbs seed
# pins to Hash[String, String]: the store was refused with no conversion
# into the slot (#8302).
module ActionController
  class CookieJar
    def [](key)
      @out[key.to_s] = value.to_s
      @out[key.to_s]
    end
  end
end
module SharedTestRunner
  def self.run(klass, names)
    if ENV["SPIN_TEST_BUNDLE"].to_s != ""
    end
    execute(klass, names)
  end
  def self.execute(klass, names)
    names.each do |m|
      t = klass.new
    end
  end
end
SharedTestRunner.run(BeforeActionContractTest, [
])
class OtlpDecoderTest
  def assert_equal(expected, actual, msg = nil)
    body = gauge_body
    body["a"]["b"]["c"] = ""
  end
end
SharedTestRunner.run(OtlpDecoderTest, [
])
