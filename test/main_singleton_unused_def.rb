# A top-level def nothing names is not emitted, so its receiverless call of a
# name main has a singleton method for has no object to be refused on: the
# program compiles and answers main's method for the call that runs.
def self.k = "m1"
def never_called = k
def never_called_arg(x) = k
puts k
