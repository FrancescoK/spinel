# def_delegators with its list in parentheses ending in a trailing comma,
# one name per line (rack-test's Rack::Test::Methods delegates to its
# current session so), and on one line
require "forwardable"
class Session
  def initialize = @log = []
  def get(path) = (@log << "GET #{path}"; @log.last)
  def post(path) = (@log << "POST #{path}"; @log.last)
  def last_request = @log.last
end
class Client
  extend Forwardable
  def initialize = @session = Session.new
  def current_session = @session

  def_delegators(:current_session,
    :get,
    :post,
    :last_request,
  )
  def_delegators(:@session, :post,)
end
c = Client.new
p c.get("/a"), c.post("/b"), c.last_request
