# A returned parameter keeps its holder's String identity. Boxing an ivar
# whose slot became shared must use the handle even if its read is String-typed.
class IvarExplicitStringIdentity
  def pass(text)
    return text
  end

  def run
    p [@text.object_id == nil.object_id, @text.equal?(nil), @text.frozen?]
    @text = +"aabc"
    result = pass(@text)
    p [@text.object_id == result.object_id, @text.equal?(result)]
    p [@text.frozen?, result.frozen?]
    @text.upcase!
    p [@text.object_id == result.object_id, @text.equal?(result)]
    p [@text, result]
    result.freeze
    p [@text.frozen?, result.frozen?]
  end
end
IvarExplicitStringIdentity.new.run

class IvarImplicitStringIdentity
  def pass(text)
    text
  end

  def run
    p [@text.object_id == nil.object_id, @text.equal?(nil), @text.frozen?]
    @text = +"aabc"
    result = pass(@text)
    p [@text.object_id == result.object_id, @text.equal?(result)]
    p [@text.frozen?, result.frozen?]
    @text.upcase!
    p [@text.object_id == result.object_id, @text.equal?(result)]
    p [@text, result]
    result.freeze
    p [@text.frozen?, result.frozen?]
  end
end
IvarImplicitStringIdentity.new.run

class LocalExplicitStringIdentity
  def pass(text)
    return text
  end

  def run
    text = +"aabc"
    result = pass(text)
    p [text.object_id == result.object_id, text.equal?(result)]
    p [text.frozen?, result.frozen?]
    text.upcase!
    p [text.object_id == result.object_id, text.equal?(result)]
    p [text, result]
    result.freeze
    p [text.frozen?, result.frozen?]
  end
end
LocalExplicitStringIdentity.new.run

class LocalImplicitStringIdentity
  def pass(text)
    text
  end

  def run
    text = +"aabc"
    result = pass(text)
    p [text.object_id == result.object_id, text.equal?(result)]
    p [text.frozen?, result.frozen?]
    text.upcase!
    p [text.object_id == result.object_id, text.equal?(result)]
    p [text, result]
    result.freeze
    p [text.frozen?, result.frozen?]
  end
end
LocalImplicitStringIdentity.new.run

class ConstantExplicitStringIdentity
  TEXT = +"aabc"
  def pass(text)
    return text
  end

  def run
    result = pass(TEXT)
    p [TEXT.object_id == result.object_id, TEXT.equal?(result)]
    p [TEXT.frozen?, result.frozen?]
    TEXT.upcase!
    p [TEXT.object_id == result.object_id, TEXT.equal?(result)]
    p [TEXT, result]
    result.freeze
    p [TEXT.frozen?, result.frozen?]
  end
end
ConstantExplicitStringIdentity.new.run

class ConstantImplicitStringIdentity
  TEXT = +"aabc"
  def pass(text)
    text
  end

  def run
    result = pass(TEXT)
    p [TEXT.object_id == result.object_id, TEXT.equal?(result)]
    p [TEXT.frozen?, result.frozen?]
    TEXT.upcase!
    p [TEXT.object_id == result.object_id, TEXT.equal?(result)]
    p [TEXT, result]
    result.freeze
    p [TEXT.frozen?, result.frozen?]
  end
end
ConstantImplicitStringIdentity.new.run
