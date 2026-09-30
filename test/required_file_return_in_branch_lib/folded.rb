class Picker
  def pick(n)
    return :one if n == 1
    :other
  end
end
return if RUBY_VERSION >= "3"
puts "folded tail (must not run)"
