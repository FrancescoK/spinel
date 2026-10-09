# An unrelated same-named writer is a second family, so the unknown receiver
# stays ambiguous; neither family's Hash slot should be widened. The custom
# subclass writer remains a method and must retain method dispatch.
class SharedController
  attr_accessor :params

  def initialize
    @params = { "first_name" => "shared" }
  end
end

class EchoController < SharedController
  def unused_write
    @params["first_name"] = "Augusta"
  end
end

class SiblingController < SharedController
end

class SeparateController
  attr_accessor :params

  def initialize
    @params = { "first_name" => "separate" }
  end

  def stored_first_name
    @params["first_name"]
  end
end

class CustomController < SeparateController
  def params=(value)
    @saw_first_name = value.key?("first_name")
  end

  def saw_first_name?
    @saw_first_name
  end
end

module Main
  def self.instantiate_controller(name)
    case name
    when "echo" then EchoController.new
    when "sibling" then SiblingController.new
    else CustomController.new
    end
  end

  def self.request_params
    params = {}
    params["first_name"] = "Ada"
    params["profile"] = { "nickname" => "Ada" }
    params
  end
end

def assign_params(receiver, value)
  receiver.params = value
end

controller = Main.instantiate_controller("custom")
assign_params(controller, Main.request_params)
puts controller.saw_first_name?
puts controller.stored_first_name
