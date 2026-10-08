# A nilable scalar propagates through a chain of pass-through methods, and the
# marking pass advances one link per round when the chain is written in
# definition order the propagation walks backwards. A fixed round cap refused
# to compile this program outright rather than mismarking it, so the cap is
# derived from the program: a round that changes anything sets one of the flags
# it counts, so it cannot run out while the pass is monotone.
# spinel: rbs-seed-run
class DcR
  def initialize(p)
    @p = p
  end

  def p_
    @p
  end
end

def dc40(x); dc39(x); end
def dc39(x); dc38(x); end
def dc38(x); dc37(x); end
def dc37(x); dc36(x); end
def dc36(x); dc35(x); end
def dc35(x); dc34(x); end
def dc34(x); dc33(x); end
def dc33(x); dc32(x); end
def dc32(x); dc31(x); end
def dc31(x); dc30(x); end
def dc30(x); dc29(x); end
def dc29(x); dc28(x); end
def dc28(x); dc27(x); end
def dc27(x); dc26(x); end
def dc26(x); dc25(x); end
def dc25(x); dc24(x); end
def dc24(x); dc23(x); end
def dc23(x); dc22(x); end
def dc22(x); dc21(x); end
def dc21(x); dc20(x); end
def dc20(x); dc19(x); end
def dc19(x); dc18(x); end
def dc18(x); dc17(x); end
def dc17(x); dc16(x); end
def dc16(x); dc15(x); end
def dc15(x); dc14(x); end
def dc14(x); dc13(x); end
def dc13(x); dc12(x); end
def dc12(x); dc11(x); end
def dc11(x); dc10(x); end
def dc10(x); dc9(x); end
def dc9(x); dc8(x); end
def dc8(x); dc7(x); end
def dc7(x); dc6(x); end
def dc6(x); dc5(x); end
def dc5(x); dc4(x); end
def dc4(x); dc3(x); end
def dc3(x); dc2(x); end
def dc2(x); dc1(x); end
def dc1(x); x.p_; end

h = {}
k = dc40(DcR.new(nil))
h[k] = "from-chain"
h[nil] = "from-literal"
puts h.length
puts h[k].inspect
puts h[nil].inspect
puts k.inspect
puts k.nil?
puts k.class

# a value that is NOT nil still keeps its number through the same chain
j = dc40(DcR.new(7))
puts j.inspect
puts j.nil?
puts j.class
