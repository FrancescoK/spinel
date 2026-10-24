# spinel: gc-stress
require 'tmpdir'
home = Dir.pwd
def return_from_chdir(path)
  Dir.chdir(path) { return :ret }
  :fell
end
p [:return_in_chdir, return_from_chdir(Dir.tmpdir)]
p Dir.pwd == home
def return_if(path, early)
  Dir.chdir(path) { return :early if early; 5 } + 1
end
p [return_if(Dir.tmpdir, true), return_if(Dir.tmpdir, false)]
p Dir.pwd == home
result = [1].each { Dir.chdir(Dir.tmpdir) { break :brk } }
p [:break_in_chdir, result]
p Dir.pwd == home
p [1, 2, 3].map { |i| Dir.chdir(Dir.tmpdir) { break i * 10 if i > 1; i } }
p Dir.pwd == home
p Dir.chdir(Dir.tmpdir) { break :inside }
p Dir.pwd == home
p Dir.chdir(Dir.tmpdir) { |d| next :next_value if d; break :not_reached }
p Dir.pwd == home
def break_or_tail(path, c)
  Dir.chdir(path) { break nil if c; 4 }
end
p [break_or_tail(Dir.tmpdir, true), break_or_tail(Dir.tmpdir, false)]
p Dir.pwd == home
def return_if_only(path, c)
  Dir.chdir(path) { return 1 if c }
end
p [return_if_only(Dir.tmpdir, true), return_if_only(Dir.tmpdir, false)]
p Dir.pwd == home
