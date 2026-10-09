# An unrelated same-named writer is a second family, so the unknown receiver
# stays ambiguous; neither family's Hash slot should be widened. The custom
# subclass writer remains a method and must retain method dispatch.
class SharedController
  attr_accessor :params

  # Seed the shared attr-writer family's params slot with a String-valued Hash.
  def initialize
    @params = { "first_name" => "shared" }
  end
end

class EchoController < SharedController
  # Trigger the unused indexed write on the inherited shared-family slot.
  # @return [String] the value written to first_name.
  def unused_write
    @params["first_name"] = "Augusta"
  end
end

class SiblingController < SharedController
end

class SeparateController
  attr_accessor :params

  # Initialize a separate writer family's params slot for the ambiguity control.
  def initialize
    @params = { "first_name" => "separate" }
  end

  # Read the separate family's slot to detect cross-family widening.
  # @return [String] the stored first_name value.
  def stored_first_name
    @params["first_name"]
  end
end

class CustomController < SeparateController
  # Preserve method dispatch for an explicit writer and record key presence.
  # @param value [Hash] params passed to this custom writer.
  # @return [Boolean] whether the incoming Hash includes first_name.
  def params=(value)
    @saw_first_name = value.key?("first_name")
  end

  # Report whether the explicit writer saw first_name in the incoming Hash.
  # @return [Boolean, nil] the recorded result, or nil before assignment.
  def saw_first_name?
    @saw_first_name
  end
end

module Main
  # Select among related and unrelated writer families at runtime.
  # @param name [String] choose echo, sibling, or the custom-writer fallback.
  # @return [Object] the selected controller instance.
  def self.instantiate_controller(name)
    case name
    when "echo" then EchoController.new
    when "sibling" then SiblingController.new
    else CustomController.new
    end
  end

  # Build a heterogeneous request Hash with a nested profile value.
  # @return [Hash] params containing first_name and profile[nickname].
  def self.request_params
    params = {}
    params["first_name"] = "Ada"
    params["profile"] = { "nickname" => "Ada" }
    params
  end
end

# Invoke params= through a runtime-unknown receiver to exercise boxed dispatch.
# @param receiver [Object] controller selected by instantiate_controller.
# @param value [Hash] heterogeneous request params to assign.
# @return [Hash] the assigned value returned by Ruby's assignment expression.
def assign_params(receiver, value)
  receiver.params = value
end

controller = Main.instantiate_controller("custom")
assign_params(controller, Main.request_params)
puts controller.saw_first_name?
puts controller.stored_first_name
