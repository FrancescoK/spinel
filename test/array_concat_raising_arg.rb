# An argument that never returns -- a method whose body only raises --
# handed to Array#concat raises before anything is appended. Its C value
# was void, which initialized the array the concat walks and did not
# compile.

class Walker
  def files_in(path)
    raise NotImplementedError, "files_in #{path}"
  end

  def run(flag)
    result = ["a"]
    result.concat files_in("x") if flag
    result
  end

  def run_value(flag)
    result = ["a"]
    flag ? result.concat(files_in("y")) : result
  end
end

w = Walker.new
p w.run(false)
p w.run_value(false)
begin
  w.run(true)
rescue NotImplementedError => e
  puts e.message
end
begin
  w.run_value(true)
rescue NotImplementedError => e
  puts e.message
end
