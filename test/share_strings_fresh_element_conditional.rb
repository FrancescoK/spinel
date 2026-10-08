# A conditional stored as a block value keeps the String its chosen arm
# answers. Both changed and unchanged bang results must reach the container.
p " a ,b,, c ".split(",", -1).map! { |x| x.strip! || x }
p " a ,b,, c ".split(",", -1).collect! { |x| x.strip! && x }
p " a ,b,, c ".split(",", -1).map! { |x|
  if x.empty?
    x
  elsif x.length == 1
    x.upcase!
    x
  else
    x.strip! || x
  end
}
p " a ,b,, c ".split(",", -1).collect! { |x|
  unless x.empty?
    x.strip! || x
  else
    x
  end
}
p " a ,b,, c ".split(",", -1).map! { |x| x.empty? ? x : (x.strip! || x) }
p " a ,b,, c ".split(",", -1).collect! { |x|
  case x.length
  when 0 then x
  when 1 then x.upcase! || x
  else x.strip! || x
  end
}
p " a ,b,, c ".split(",", -1).map { |x| x.strip! || x }
p " a ,b,, c ".split(",", -1).collect { |x|
  case x.length
  when 0 then x
  else x.strip! || x
  end
}
# A next takes the same conditional route, including from a framed body.
p " a ,b,, c ".split(",", -1).map! { |x|
  next (x.strip! || x) unless x.empty?
  x
}
# An explicit element store uses the same boxing as a collected block value.
p [1, 2, 3].each_with_object([]) { |i, out|
  x = i.to_s
  x << "!"
  out << (case i
          when 1 then x.strip! || x
          when 2 then i == 2 ? x : nil
          else x unless i == 0
          end)
}
