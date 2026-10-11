# Spinel package: timeout
#
# Timeout.timeout(sec, klass = nil, message = nil) { |sec| ... } from Ruby's
# standard library, with Timeout::Error and Timeout::ExitException. A
# nil or zero sec runs the block with no limit; a negative one raises
# ArgumentError. When the time runs out the block is interrupted with klass
# (and message, "execution expired" by default); with no klass it is
# interrupted with an ExitException, which reaches the caller as
# Timeout::Error, so a `rescue StandardError` inside the block does not
# swallow it. `include Timeout` adds a private #timeout.
#
# CRuby's timeout.rb keeps one shared watcher thread; here each call starts
# its own, which sleeps and then raises into the caller unless the block
# has finished. A raise queued just as the block finishes is still taken
# before Timeout.timeout returns. The interrupt goes through Thread#raise,
# which Spinel does not deliver to the main thread yet
# (docs/limitations.md): there the block runs to completion and nothing is
# raised.

module Timeout
  VERSION = "0.6.1"

  class ExitException < Exception
    def exception(*)
      self
    end
  end

  class Error < RuntimeError
  end

  def self.timeout(sec, klass = nil, message = nil)
    if sec.nil? || sec.zero?
      yield(sec)
    else
      raise ArgumentError, "Timeout sec must be a non-negative number" if 0 > sec

      message ||= "execution expired"
      current = Thread.current
      lock = Thread::Mutex.new
      done = false
      fired = false
      exc = klass ? nil : ExitException.new(message)
      watcher = Thread.new do
        sleep sec
        lock.synchronize do
          unless done
            fired = true
            if exc
              current.raise(exc)
            else
              current.raise(klass, message)
            end
          end
        end
      end
      begin
        result = begin
          yield(sec)
        ensure
          lock.synchronize { done = true }
          watcher.kill
        end
        # The watcher may have queued its raise just as the block finished.
        # Take it here, where the rescue below still sees it, rather than at
        # the caller's next blocking call.
        Thread.pass if fired
        result
      rescue ExitException => e
        raise Error, message if exc && exc.equal?(e)
        raise
      end
    end
  end

  private

  def timeout(sec, klass = nil, message = nil, &block)
    Timeout.timeout(sec, klass, message, &block)
  end
end
