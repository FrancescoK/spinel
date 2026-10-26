# A String reopening's method that a required file defines answers the
# calls after the require, the builtin the ones before it.
x = []
"ab".each_line { |l| x << l }
p x
require_relative "string_reopen_lib"
y = []
"ab".each_line { |l| y << l }
p y
