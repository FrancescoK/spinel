require "erb"

# `<%= name %>` from symbol keys; a comment tag leaves its line empty
template = <<~T
  #!/bin/sh
  <%# a comment %>
  ORIGIN=<%= origin %>
  NAME=<%= server_name %>
T
puts ERB.new(template).result_with_hash(origin: "https://example.com", server_name: "web1")

# trim_mode "-": `-%>` drops the newline after the tag; `<%%` is a literal `<%`
puts ERB.new("a\n  <%= v -%>\nb <%% literal %%>\n", trim_mode: "-").result_with_hash(v: 42)

# `<%-` drops the indentation before a tag that starts its line, not
# the text before one in mid-line
puts ERB.new("x\n    <%- -%>\ny <%- %>z\n", trim_mode: "-").result_with_hash({})

# string keys bind the same local
puts ERB.new("<%= name %>!").result_with_hash("name" => "string key")

# a name the Hash does not bind
begin
  ERB.new("<%= missing %>").result_with_hash(other: 1)
rescue NameError => e
  puts e.class
end
