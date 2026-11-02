# A module body builds its classes from a Hash with const_set and Class.new,
# and the classes answer through a class << self attr_reader.
module HTTPStatus
  class Status < StandardError
    class << self
      attr_reader :code, :reason_phrase
    end
    def code() self::class::code end
    def reason_phrase() self::class::reason_phrase end
    alias to_i code
  end
  class Info < Status; end
  class Success < Status; end
  class ClientError < Status; end
  StatusMessage = { 100 => 'Continue', 200 => 'OK', 404 => 'Not Found', 414 => 'Request-URI Too Large' }
  CodeToError = {}
  StatusMessage.each { |code, message|
    message.freeze
    var_name = message.gsub(/[ \-]/, '_').upcase
    err_name = message.gsub(/[ \-]/, '')
    case code
    when 100...200; parent = Info
    when 200...300; parent = Success
    when 400...500; parent = ClientError
    end
    const_set("RC_#{var_name}", code)
    err_class = Class.new(parent)
    err_class.instance_variable_set(:@code, code)
    err_class.instance_variable_set(:@reason_phrase, message)
    const_set(err_name, err_class)
    CodeToError[code] = err_class
  }
  def self.[](code) CodeToError[code] end
end
p HTTPStatus::RC_OK
p HTTPStatus::RC_REQUEST_URI_TOO_LARGE
p HTTPStatus::NotFound.new.code
p HTTPStatus::OK.superclass
p HTTPStatus::Continue.superclass
p HTTPStatus[404].new.reason_phrase
p HTTPStatus::CodeToError.size
p HTTPStatus::Status.code
begin
  raise HTTPStatus::RequestURITooLarge, "too long"
rescue HTTPStatus::ClientError => e
  p [e.class, e.code, e.to_i, e.reason_phrase, e.message]
end
