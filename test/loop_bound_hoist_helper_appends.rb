# A while loop whose predicate measures a String local (`s.size`, `s.length`)
# measures it again after every pass that can change it. A method of the
# program's own (an instance method, or a class or module method called on a
# constant or on `self.class`) that appends to, empties or slices its
# parameter changes the caller's String, so a loop calling one cannot keep
# the length it took ahead of the loop: it ran on forever. A callee that
# only reads the String leaves the length alone, and the loop around one
# ends at the same place.
# Each shape is a method of its own, so no other shape's use of a local or
# of a helper changes how the helper takes its argument.

def add(t) = t << "!"
def add_after(n, t) = t << "!" * n
def add_via(t) = add(t)
def swap_in(t) = t.replace(t + "!")
def cut(t) = t.slice!(0)
def wipe(t) = t.clear
def peek(t, i) = t.getbyte(i)
def grow(a) = a << 1
def put(h) = h[h.size] = 1
def twice
  yield
  yield
end

class Pad
  def add(t) = t << "!"
end

class Cls
  def self.cadd(t) = t << "!"
  def run(s)
    while s.size < 6
      self.class.cadd(s)
    end
    s
  end
end

module Mod
  def self.madd(t) = t << "!"
  class Inner
    def self.iadd(t) = t << "!"
  end
end

class Single
  class << self
    def sadd(t) = t << "!"
  end
end

module Ext
  extend self
  def eadd(t) = t << "!"
end

class Holder
  def initialize(s) = @s = s
  def bump = @s << "!"
end

# the helper appends
def direct
  s = +"ab"
  while s.size < 6
    add(s)
  end
  p s
end
direct

# the String is not the first argument
def second_arg
  s = +"ab"
  while s.length < 6
    add_after(1, s)
  end
  p s
end
second_arg

# through a chain of helpers, in an until loop
def chained
  s = +"ab"
  until s.size >= 6
    add_via(s)
  end
  p s
end
chained

# a helper that replaces, cuts or empties it
def replaced
  s = +"ab"
  while s.size < 6
    swap_in(s)
  end
  p s
end
replaced

def cut_down
  s = +"abcdefgh"
  while s.size > 3
    cut(s)
  end
  p s
end
cut_down

def emptied
  s = +"abcdefgh"
  while s.size > 0
    wipe(s)
  end
  p s
end
emptied

# the call is a method of an object, or named at run time
def on_object
  o = Pad.new
  s = +"ab"
  while s.size < 6
    o.add(s)
  end
  p s
end
on_object

def by_send
  s = +"ab"
  while s.size < 6
    send(:add, s)
  end
  p s
end
by_send

# the call is a class method, on a class, a module, a nested constant, the
# singleton class or `self.class`, or a module that extends itself
def on_class
  s = +"ab"
  while s.size < 6
    Cls.cadd(s)
  end
  p s
end
on_class

def on_module
  s = +"ab"
  while s.size < 6
    Mod.madd(s)
  end
  p s
end
on_module

def on_nested_constant
  s = +"ab"
  while s.size < 6
    Mod::Inner.iadd(s)
  end
  p s
end
on_nested_constant

def on_singleton
  s = +"ab"
  while s.size < 6
    Single.sadd(s)
  end
  p s
end
on_singleton

def on_extended_module
  s = +"ab"
  while s.size < 6
    Ext.eadd(s)
  end
  p s
end
on_extended_module

p Cls.new.run(+"ab")

# the call sits in a branch, a block, a longer condition or a post-test loop
def in_branch
  s = +"ab"
  while s.size < 6
    if s.size > 100
      puts "never"
    else
      add(s)
    end
  end
  p s
end
in_branch

def in_block
  s = +"ab"
  while s.size < 6
    [1].each { add(s) }
  end
  p s
end
in_block

def long_condition
  s = +"ab"
  i = 0
  while s.size < 6 && i < 10
    add(s)
    i += 1
  end
  p s
end
long_condition

def post_test
  s = +"ab"
  begin
    add(s)
  end while s.size < 6
  p s
end
post_test

# the call sits forty branches deep, further down than the walk that looks for
# it reads
def deeply_nested
  s = +"ab"
  while s.size < 6
    if true
      if true
        if true
          if true
            if true
              if true
                if true
                  if true
                    if true
                      if true
                        if true
                          if true
                            if true
                              if true
                                if true
                                  if true
                                    if true
                                      if true
                                        if true
                                          if true
                                            if true
                                              if true
                                                if true
                                                  if true
                                                    if true
                                                      if true
                                                        if true
                                                          if true
                                                            if true
                                                              if true
                                                                if true
                                                                  if true
                                                                    if true
                                                                      if true
                                                                        if true
                                                                          if true
                                                                            if true
                                                                              if true
                                                                                if true
                                                                                  if true
                                                                                    add(s)
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  p s
end
deeply_nested

# the body reads the length too
def reads_length
  s = +"ab"
  while s.size < 5
    puts s.size
    add(s)
  end
end
reads_length

# at the top level of the program
s = +"ab"
while s.size < 6
  add(s)
end
p s

# a block or a lambda that appends, and an object holding the same String
def block_appends
  s = +"ab"
  while s.size < 6
    twice { s << "!" }
  end
  p s
end
block_appends

def lambda_appends
  s = +"ab"
  more = -> { s << "!" }
  while s.size < 6
    more.call
  end
  p s
end
lambda_appends

def held_in_ivar
  s = +"ab"
  h = Holder.new(s)
  while s.size < 6
    h.bump
  end
  p s
end
held_in_ivar

# an Array or a Hash grown by a callee
def array_grown
  a = []
  while a.size < 3
    grow(a)
  end
  p a
end
array_grown

def hash_grown
  h = {}
  while h.size < 3
    put(h)
  end
  p h
end
hash_grown

# a callee that only reads the String
def only_reads
  s = +"abcdef"
  i = 0
  sum = 0
  while i < s.size
    sum += peek(s, i)
    i += 1
  end
  p sum
end
only_reads
