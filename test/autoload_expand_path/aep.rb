# required by main: its autoloads go to its end, after the module body
module Aep
  autoload :INDEX, File.expand_path('aep/index', __dir__)

  %w[
    FIRST
    SECOND
  ].each do |const_name|
    autoload const_name, File.expand_path('aep/lazy', __dir__)
  end

  %w[LIST].each do |const_name|
    autoload(const_name, File.expand_path("aep/list", __dir__))
  end

  def self.first_plus = FIRST + 1
end
