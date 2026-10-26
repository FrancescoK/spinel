# frozen_string_literal: true
module Store
  class Exception < ::StandardError
    attr_reader :code
    def message
      [super, code && "code #{code}"].compact.join(": ")
    end
  end
  class QueryError < Exception; end
  class Closed < Exception; end
end
require_relative 'raise_program_class'

begin
  CextRaiser.fail_with(1)
rescue Store::QueryError => e
  p e.class
  p e.code
  puts e.message
end
begin
  CextRaiser.fail_plain
rescue Store::Closed => e
  p e.class
  puts e.message
end
begin
  CextRaiser.fail_with(5)
rescue Store::Exception => e
  p e.is_a?(Store::QueryError)
end
begin
  CextRaiser.fail_with(7)
rescue StandardError => e
  p [e.class, e.code]
end
p CextRaiser.errinfo
begin
  CextRaiser.fail_with(2)
rescue Store::QueryError
  p CextRaiser.errinfo.class
end
p CextRaiser.errinfo
