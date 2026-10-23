# DidYouMean::SpellChecker#correct: the words of the dictionary close to the
# given one, the closest first, never the given word itself. The cases are
# the ones ruby/did_you_mean tests.
require "did_you_mean"

def correct(input, dictionary) = p DidYouMean::SpellChecker.new(dictionary: dictionary).correct(input)

# mistypes
correct("doo", %w[foo fork])
correct("meail", %w[email fail eval])
correct("fial", %w[email fail eval])
correct("afil", %w[email fail eval])
correct("eavl", %w[email fail eval])
correct("veal", %w[email fail eval])
correct("suv!", %w[sub gsub sub!])
correct("suv", %w[sub gsub sub!])
correct("FOo", %w[Foo FOo])
correct("gsuv!", %w[sub gsub gsub!])
correct("ssub!", %w[sub sub! gsub gsub!])
correct("group", %w[groups group_url groups_url group_path])

groups = %w[GroupMembership GroupMembershipPolicy GroupMembershipDecorator
            GroupMembershipSerializer GroupHelper Group GroupMailer NullGroupMembership]
correct("GroupMemberhip", groups)
correct("GroupMemberhipDecorator", groups)

names = %w[first_name_change first_name_changed? first_name_will_change!]
correct("first_name_change!", names)
correct("product_path", %w[proc])
correct("fooo", %w[fork])

# misspellings
correct("dependents", %w[descendants])
correct("drag", %w[drag_to])
correct("set_result", %w[set_result_count])

# ranked by similarity
correct("name123456", %w[name12 name123 name1234 name12345 name123456])

# the given word is not suggested, String or Symbol
correct("input", %w[input])
correct("input", [:input])
correct(:input, %w[input])

# Symbols in the dictionary, an instance variable's @
correct("verbos", [:verbose, :version, "help"])
correct("@nmae", %w[@name @age])
