# A constant and a class sharing a leaf name in different modules (webrick's
# Config::FileHandler Hash and HTTPServlet::FileHandler class) are two
# constants: the class's path reads the class, as a receiver and as a value
# held in a local or a Hash, and the constant's path reads the constant.
module Web
  module Config
    FileHandler = { root: "/" }
    def self.root = FileHandler[:root]
  end
  module Servlet
    class FileHandler
      def self.get_instance(path) = new(path)
      def initialize(path) = @path = path
      def service = "serving #{@path}"
    end
    def self.handler = FileHandler
  end
end
puts Web::Servlet::FileHandler.get_instance("/a").service
k = Web::Servlet::FileHandler
puts k.get_instance("/b").service
table = { "txt" => Web::Servlet::FileHandler }
puts table["txt"].get_instance("/c").service
puts Web::Servlet.handler.get_instance("/d").service
p Web::Config::FileHandler
p Web::Config.root
p Web::Config.const_get(:FileHandler)
p Web::Servlet.const_get(:FileHandler).get_instance("/e").service

# A top-level constant beside a nested class of the same leaf, and a nested
# constant beside a top-level class.
Settings = [1, 2]
module App
  class Settings
    def self.load = "App::Settings.load"
  end
end
p Settings
puts App::Settings.load
s = App::Settings
puts s.load

class Handler
  def self.name2 = "top Handler"
end
module Table
  Handler = [3, 4]
  def self.read = Handler
end
puts Handler.name2
p Table::Handler
p Table.read

# The constant's path read through a subclass or an includer still finds it.
class Base
  Item = [5, 6]
end
class Sub < Base; end
module Other
  class Item; end
  class Settings; end
end
p Sub::Item
p Sub.const_get(:Item)
module Holder
  Key = { k: 1 }
end
module Elsewhere
  class Key; end
end
class Includer
  include Holder
end
p Includer::Key
class SettingsUser
  include App
end
puts SettingsUser::Settings.load
puts App.const_get(:Settings).load
p Object.const_get(:Settings)

# A constant whose own name merely ends like a qualified one is not taken
# for another constant.
class Leaf; end
class Odd
  X__Leaf = 1
end
p Odd.const_get(:Leaf)
p Odd.const_defined?(:Leaf, false)
