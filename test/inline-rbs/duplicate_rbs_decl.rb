# spinel: not-cruby -- two .rbs declarations of one method are refused
# Two .rbs files declare Router#path with different signatures, and the
# method also carries an inline annotation that agrees with one of them. The
# annotation does not choose between the two: --rbs refuses the pair, naming
# both, exactly as it does without the annotation.
class Router
  #: (Integer) -> String
  def path(id)
    "/r/" + id.to_s
  end
end

puts Router.new.path(1)
