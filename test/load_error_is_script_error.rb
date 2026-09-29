# LoadError sits under ScriptError, not StandardError: a bare rescue and
# `rescue StandardError` let it through, `rescue ScriptError` catches it.
p LoadError.new("x").is_a?(ScriptError), LoadError.new("x").is_a?(StandardError)
begin
  begin
    raise LoadError, "l"
  rescue StandardError => e
    p [:std, e.message]
  end
rescue ScriptError => e
  p [:script, e.message]
end
begin
  begin
    raise LoadError, "m"
  rescue => e
    p [:bare, e.message]
  end
rescue LoadError => e
  p [:load, e.message]
end
