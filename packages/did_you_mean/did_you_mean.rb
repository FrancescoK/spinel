# Spinel bundled `did_you_mean`.
#
# The spell checker behind "Did you mean?": DidYouMean::SpellChecker picks
# the words of a dictionary that are close to a misspelled one, and
# DidYouMean.formatter writes them under a message. optparse requires it and
# uses both for an option it does not know.
#
# The suggestions CRuby adds to NameError, NoMethodError, KeyError and
# LoadError are not here: finding them needs the receiver's methods, the
# local variables or the load path at run time.
require "did_you_mean/levenshtein"
require "did_you_mean/jaro_winkler"
require "did_you_mean/spell_checker"
require "did_you_mean/formatter"

module DidYouMean
  VERSION = "2.0.0"

  @formatter = Formatter

  def self.formatter = @formatter

  def self.formatter=(formatter)
    @formatter = formatter
  end
end
