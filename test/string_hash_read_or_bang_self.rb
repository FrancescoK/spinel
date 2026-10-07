# `ACR[word] || word.capitalize! || word` -- a String-to-String Hash's read,
# else the String changed in place (the bang answers nil when nothing
# changed, so the chain falls to the String itself). activesupport's
# Inflector#camelize picks its words so.
ACR = { "html" => "HTML" }

def pick(word)
  word = word.dup
  ACR[word] || word.capitalize! || word
end

def camelize(term)
  term.to_s.gsub(/(?:_|(\/))([a-z\d]*)/i) do
    word = $2
    substituted = ACR[word] || word.capitalize! || word
    $1 ? "::#{substituted}" : substituted
  end
end

p pick("ab"), pick("Ab"), pick("html")
p camelize("x_hello_world"), camelize("page/html_admin"), camelize(:active_model)
