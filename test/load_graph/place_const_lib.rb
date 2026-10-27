begin
  p LIMIT
rescue NameError
  p :name_error
end
