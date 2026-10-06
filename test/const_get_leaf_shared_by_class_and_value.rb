# Two constants of one name in different modules, one a class and one a
# value (webrick's HTTPServlet::FileHandler class and Config::FileHandler
# Hash): `M.const_get(:Name)` answers the one M holds, and with inherit
# false a module holding neither raises NameError -- also for `self`.
module Config
  FileHandler = { root: "/" }
end
module Servlet
  class FileHandler
    def self.run = "files"
  end
end
module Handler
  class WEBrick
    def self.run = "webrick"
  end
  def self.[](name)
    const_get(name.to_sym, false)
  rescue NameError
    nil
  end
  def self.lit = self.const_get(:WEBrick, false)
  def self.miss = self.const_get(:FileHandler, false)
end
p Servlet.const_get(:FileHandler).run
p Config.const_get(:FileHandler)
p Config.const_get(:FileHandler, false)
p Handler[:WEBrick].run, Handler[:FileHandler], Handler.lit.run
begin
  Handler.miss
rescue NameError => e
  p e.class
end
