# spinel: reject-subclass: a def under a condition only the run time decides, in a Class.new
# A Class.new block becomes a class body after the run-time condition defs
# are lowered, so a def there is refused rather than defined whatever the
# condition said (CRuby: NoMethodError when the branch does not run).
Foo = Class.new do
  if ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def foo = 1
  end
end
p Foo.new.foo
