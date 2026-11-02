Config = {a: 1}
module Rack
  class Config
    def self.w = :rack
  end
end
p Config[:a]
p Rack::Config.w
