# printf and IO#printf, with no other formatting call in the program, convert
# a user object through its #to_f for a Float directive.
class V
  def to_f
    1.25
  end
end
printf("%.1f\n", V.new)
$stdout.printf("%.2f\n", V.new)
