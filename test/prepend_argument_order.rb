module PrependFirst
  def value = "first"
end
module PrependSecond
  def value = "second"
end
class PrependTogether
  prepend PrependFirst, PrependSecond
end
class PrependSequential
  prepend PrependFirst
  prepend PrependSecond
end
class PrependReverse
  prepend PrependSecond, PrependFirst
end
p PrependTogether.new.value
p PrependSequential.new.value
p PrependReverse.new.value
