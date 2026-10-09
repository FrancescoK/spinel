# A boxed receiver whose writer is inherited by sibling subclasses still has
# one effective attr-writer family. The unused indexed write narrows the
# inherited @params field; the dynamic assignment below must widen that shared
# slot back to the incoming heterogeneous Hash representation.
class ParentController
  attr_accessor :params

  def initialize
    @params = {}
  end
end

class ApiController < ParentController
end

class EchoController < ApiController
  def process_action
    @params.key?("first_name") &&
      @params.fetch("first_name", nil) == "Ada" &&
      @params.fetch("profile", {}).fetch("nickname", nil) == "Ada"
  end

  def unused_write
    @params["first_name"] = "Augusta"
  end
end

class OtherController < ApiController
  def process_action
    false
  end
end

module Main
  def self.instantiate_controller(name)
    case name
    when "echo" then EchoController.new
    else OtherController.new
    end
  end

  def self.request_params
    params = {}
    params["first_name"] = "Ada"
    params["profile"] = { "nickname" => "Ada" }
    params
  end
end

controller = Main.instantiate_controller("echo")
controller.params = Main.request_params
puts controller.process_action
