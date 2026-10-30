# `def method_missing(symbol, ...)` forwarding `public_send(symbol, ...)`:
# the `...` is empty at every call, so the method has no forwarded slot,
# and the forward handed the leading parameter on -- the dynamic send's
# arms took the name symbol as their first argument.
class Collector
  def initialize = @responses = []
  def any(*args, &block)
    @responses << [:any, args]
    block ? block.call : nil
  end
  def custom(mime_type, &block)
    @responses << [:custom, mime_type]
  end
  def responses = @responses

  private
    def method_missing(symbol, ...)
      if %i[html json xml].include?(symbol)
        public_send(symbol, ...)
      else
        super
      end
    end
    def respond_to_missing?(symbol, include_private = false)
      %i[html json xml].include?(symbol) || super
    end
end
class Collector
  def html(*args, &block) = any(*args, &block)
  def json(mime = :json, &block) = custom(mime, &block)
end
c = Collector.new
c.html(1, 2)
c.json
c.json(:j2) { }
begin
  c.pdf
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[0, 20]}"
end
p c.responses
