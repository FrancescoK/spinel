# spinel: not-cruby -- CRuby's ERB evaluates any Ruby in a tag; Spinel's renders only `<%= name %>` and says so.
# Code a compiled program cannot eval raises NotImplementedError naming the
# tag, instead of answering the template unrendered or rendering something
# else. So does a trim_mode other than "-".
require "erb"

["<%= 1 + 1 %>", "<% if ok %>y<% end %>", "<%= name.upcase %>"].each do |t|
  begin
    ERB.new(t).result_with_hash(ok: true, name: "n")
  rescue NotImplementedError => e
    puts e.message
  end
end

begin
  ERB.new("x\n  <%-# c %>y\n", trim_mode: "-").result_with_hash({})
rescue NotImplementedError => e
  puts e.message
end

begin
  ERB.new("<%= v %>", trim_mode: "<>")
rescue NotImplementedError => e
  puts e.message
end

begin
  ERB.new("<%= v %>").result
rescue NotImplementedError => e
  puts e.message
end
