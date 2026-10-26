class String
  def each_line
    yield "custom"
    self
  end
end
