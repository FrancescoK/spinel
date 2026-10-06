# Shapes beside the refused container routes (a global Array's String
# elements mutated through it; a String a method stores into its caller's
# Array, mutated through the caller's element): the element is no String or
# already the shared handle, the global is not mutated through, or the
# method's own element mutation makes the stored String the handle, so each
# compiles and answers as CRuby.
$g14 = []; $g14.push(+"y"); $g14.each { |y29| p y29 + "?" }; p $g14
$g15 = {a: +"y"}; $g15[:a] << "?"; p $g15
$g16 = [[1]]; $g16[0] << 2; $g16.each { |y31| y31 << 3 }; p $g16
s17 = +"y"; u17 = s17; u17 << ""; $g17 = [s17]; $g17[0] << "?"; $g17.each { |y32| y32 << "!" }; p s17, $g17
l18 = []; l18.push(+"y"); l18.each { |y33| y33 << "?" }; p l18

def keep2(a, s) = (a << s; a[0] << "?")
s19 = +"n"; a19 = []; keep2(a19, s19); a19[0] << "!"; p s19
def keep1(a) = (a << 1)
a20 = []; keep1(a20); a20 << 2; p a20
# a method that rebinds its parameter to a new Array stores into that one
def keep3(a)
  a = []
  a << +"n"
end
a21 = [+"y"]; keep3(a21); a21[0] << "?"; p a21
