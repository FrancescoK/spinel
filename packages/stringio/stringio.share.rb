# StringIO's share declarations, which the parser reads after stringio.rb
# only under --share-strings: a build without the flag parses no node of
# them (see native_share in the native binding DSL).
module StringIOPackage
  native_struct "StringIO"   # the class the declarations below are for
  # Under --share-strings, a StringIO is CRuby's: it reads and writes the
  # String it is opened on, and #string answers that String itself.
  #   native_share "name", [arg_specs], "kind"[, "csym"]   (or "name",
  #   "kind" for every binding of the name; "new" names the constructors):
  #   kind "keeps" (a constructor's object keeps its first String argument,
  #   or a String of its own), "answers" (answers the String kept),
  #   "changes" (changes it) or "fresh" (answers a new String, one no other
  #   name holds); csym is the form taking or answering that
  #   String as its shared handle (sp_String *). The handle forms are used
  #   only where the analysis shares the String. Strings, not Symbols: a
  #   binding's Symbols join the program's own.
  native_share "new",      [],                 "keeps",   "sp_StringIO_new_hn"
  native_share "new",      [:string],          "keeps",   "sp_StringIO_new_h"
  native_share "new",      [:string, :string], "keeps",   "sp_StringIO_new_hm"
  native_share "new",      [:string, :string], "changes"   # mode "w" truncates it
  native_share "string",   [],                 "answers", "sp_StringIO_string_h"
  native_share "write",    "changes"
  native_share "<<",       "changes"
  native_share "puts",     "changes"
  native_share "print",    "changes"
  native_share "putc",     "changes"
  native_share "truncate", "changes"
  # read and read(length) answer a new String (read(length, buffer) answers
  # the buffer)
  native_share "read",     [],                 "fresh"
  native_share "read",     [:int],             "fresh"
  native_share "readline", "fresh"
end
