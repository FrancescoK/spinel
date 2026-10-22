# did_you_mean

`require "did_you_mean"`: DidYouMean::SpellChecker, the Levenshtein, Jaro
and Jaro-Winkler distances it ranks words by, DidYouMean::Formatter and
DidYouMean.formatter.

It is written here, after ruby/did_you_mean 2.0.0, the version CRuby 4.0
ships, and answers what that version answers.

- Source: <https://github.com/ruby/did_you_mean>, release v2.0.0, commit
  `1cce337962d51ee90bb7ff51a51a803fc2384e0e`
- License: MIT (`LICENSE.txt`, copied from that commit)

Not here: the suggestions CRuby adds to NameError, NoMethodError, KeyError
and LoadError, and the checkers and formatters behind them. In CRuby the
library is loaded before the program; here a program requires it.

The tests in `test/` run in the gate, with `.expected` from CRuby 4.0.
