module DidYouMean
  # Writes suggestions as lines to append to a message, each one under the
  # first. No suggestions write nothing.
  class Formatter
    HEADER = "Did you mean?  "

    def self.message_for(corrections)
      return "" if corrections.empty?

      "\n#{HEADER}#{corrections.join("\n" + " " * HEADER.size)}"
    end

    def message_for(corrections)
      warn "The instance method #message_for has been deprecated. " \
           "Please use the class method DidYouMean::Formatter.message_for(...) instead."
      self.class.message_for(corrections)
    end
  end

  PlainFormatter = Formatter
end
