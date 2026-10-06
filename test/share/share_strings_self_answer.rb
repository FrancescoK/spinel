# Flag-only: without the flag (as on master) a change through the answer misses the String.
# A call that answers its receiver -- `concat` with any number of
# arguments, `append_as_bytes`, `bytesplice`, `each_char`/`each_line`/`scan`
# with a block, `tap` -- answers that String itself: a name bound to the
# answer, a box holding it, and the receiver are one String.
s1 = +"hello"; t1 = s1.concat("a", "b"); p t1.equal?(s1)
s2 = +"hello"; t2 = s2.concat; p t2.equal?(s2)
s3 = +"hello"; t3 = s3.append_as_bytes("x"); p t3.equal?(s3)
s4 = +"hello"; t4 = s4.bytesplice(0, 1, "H"); p t4.equal?(s4)
s5 = +"hello"; t5 = s5.each_char { |c| c }; p t5.equal?(s5)
s6 = +"hello"; t6 = s6.scan("l") { |m| m }; p t6.equal?(s6)
s7 = +"hello"; t7 = s7.tap { |v| v }; p t7.equal?(s7)
s8 = +"hello"; t8 = s8.frozen? ? :f : s8.concat("!"); p t8.equal?(s8)
s9 = +"hello"; t9 = s9.concat("a", "b"); t9 << "!"; p s9
s10 = +"hello"; t10 = s10.tap { |v| v }; t10 << "!"; p s10
s11 = +"hello"; t11 = s11.each_line { |l| l }; s11 << "~"; p t11
