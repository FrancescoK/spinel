# respond_to?(:send), (:__send__) and (:public_send) compile and answer true,
# as CRuby answers, where the compiler could refuse the program for a
# runtime-name send the program does not contain.
S = Struct.new(:a)
p S.new(1).respond_to?(:send)
class K; end
k = K.new
p k.respond_to?(:send)
p k.respond_to?(:public_send)
p k.respond_to?(:__send__)
p 5.respond_to?(:send)
p "s".respond_to?(:__send__)
p [1, "s"][0].respond_to?(:public_send)
p nil.respond_to?(:send)
p k.respond_to?("send")
