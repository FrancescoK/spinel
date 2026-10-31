puts "mix path lib loaded"
module MixPath
  module Inner
    module Inc
      X = 5
      def inc = "inc"
    end
    module Ext
      def ext = "ext"
    end
    module Pre
      def pre = "pre"
    end
  end
  class Base
    def base = "base"
    def self.make = new
  end
end
