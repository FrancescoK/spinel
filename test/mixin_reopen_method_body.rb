# A call in a method body runs ahead of a later mixin only under a statement
# that runs after both its def and the class's first body. A require in a
# class body (`class Account; require_relative "account/joinable"; include
# Account::Joinable; end`) puts the required file's `class Account; module
# Joinable` body right ahead of the include, so the code the program ran
# before that (a Rails app's boot) cannot have called the method on an
# Account. A prepend into a namespaced class (`class Turbo::Channel; prepend
# Auth; end`) hands a call to the class's own method until it has run.
puts "boot"
class Controller
  def create = Account.new.reset_join_code
end
class Account
  module Joinable
    def reset_join_code = "reset"
  end
end
class Account
  include Account::Joinable
end
puts Controller.new.create

module Auth
  def subscribed = "auth " + super
end
module Turbo
  class Channel
    def subscribed = "subscribed"
  end
end
class Runner
  def run(ch) = ch.subscribed
end
puts Runner.new.run(Turbo::Channel.new)
class Turbo::Channel
  prepend Auth
end
puts Runner.new.run(Turbo::Channel.new)
