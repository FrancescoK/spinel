# A boxed receiver whose writer is inherited by sibling subclasses still has
# one effective attr-writer family. The unused indexed write narrows the
# inherited @params field; the dynamic assignment below must widen that shared
# slot back to the incoming heterogeneous Hash representation.
class ParentController
  attr_accessor :params

  # Initialize the inherited params slot before the dynamically dispatched write.
  def initialize
    @params = {}
  end
end

class ApiController < ParentController
end

class EchoController < ApiController
  # Check top-level and nested values after assignment through a boxed receiver.
  # @return [Boolean] whether both request fields retain their expected values.
  def process_action
    @params.key?("first_name") &&
      @params.fetch("first_name", nil) == "Ada" &&
      @params.fetch("profile", {}).fetch("nickname", nil) == "Ada"
  end

  # Model the unused indexed write that narrows the inherited @params slot.
  # @return [String] the value written to first_name.
  def unused_write
    @params["first_name"] = "Augusta"
  end
end

class OtherController < ApiController
  # Supply the sibling alternative for runtime controller selection.
  # @return [Boolean] false, so only the echo branch satisfies the fixture.
  def process_action
    false
  end
end

module Main
  # Select a sibling class at runtime to make the controller receiver polymorphic.
  # @param name [String] select EchoController with "echo"; other names select its sibling.
  # @return [Object] the selected controller instance.
  def self.instantiate_controller(name)
    case name
    when "echo" then EchoController.new
    else OtherController.new
    end
  end

  # Build the heterogeneous request Hash, including a nested profile Hash.
  # @return [Hash] params with first_name and profile[nickname] set to "Ada".
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
