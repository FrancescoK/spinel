# emit_operands_in_order hoists a call's side-effecting operands into temps,
# in source order, so C's own unspecified operand order cannot run them out
# of turn. Past MAX_ARG_OVERRIDE (64) operands it used to give up on the
# hoist and leave the arguments to C's order instead of CRuby's.

$log = []
def lg(x) = ($log << x; x)

class Sum
  def self.total(*values) = values.sum

  def self.bar(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10,
               a11, a12, a13, a14, a15, a16, a17, a18, a19, a20,
               a21, a22, a23, a24, a25, a26, a27, a28, a29, a30,
               a31, a32, a33, a34, a35, a36, a37, a38, a39, a40,
               a41, a42, a43, a44, a45, a46, a47, a48, a49, a50,
               a51, a52, a53, a54, a55, a56, a57, a58, a59, a60,
               a61, a62, a63, a64, a65, a66, a67, a68, a69, a70)
    [a1, a70].sum
  end
end

r = Sum.bar(lg(1), lg(2), lg(3), lg(4), lg(5), lg(6), lg(7), lg(8), lg(9), lg(10),
            lg(11), lg(12), lg(13), lg(14), lg(15), lg(16), lg(17), lg(18), lg(19), lg(20),
            lg(21), lg(22), lg(23), lg(24), lg(25), lg(26), lg(27), lg(28), lg(29), lg(30),
            lg(31), lg(32), lg(33), lg(34), lg(35), lg(36), lg(37), lg(38), lg(39), lg(40),
            lg(41), lg(42), lg(43), lg(44), lg(45), lg(46), lg(47), lg(48), lg(49), lg(50),
            lg(51), lg(52), lg(53), lg(54), lg(55), lg(56), lg(57), lg(58), lg(59), lg(60),
            lg(61), lg(62), lg(63), lg(64), lg(65), lg(66), lg(67), lg(68), lg(69), lg(70))
p [r, $log]
