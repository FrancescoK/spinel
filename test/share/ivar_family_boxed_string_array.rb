# A String Array instance variable whose elements the rule shares is boxed in
# its whole class family: an abstract class between the base that writes it
# and the class that uses it kept a String Array copy, a different struct
# layout from the base's, and the program was refused (#8328, a Rails
# application's ActiveRecord::Base#@errors under ApplicationRecord).
class Domain
  def initialize(name) = @name = name
  def qualify = (@name << " is blank"; nil)
end

class Base
  def initialize
    @errors = []
  end

  def errors
    @errors
  end

  def valid? = @errors.empty?
end

class AppRecord < Base
  def self.abstract?
    true
  end

  def to_param = "app"
end

class Article < AppRecord
  def validate(title)
    errors << "Title can't be blank" if title.empty?
    m = +"Body"
    Domain.new(m).qualify
    errors << m
    @last = m
    self
  end

  def same? = errors.last.equal?(@last)
  def dummy
    self
  end
end

a = Article.new.validate("")
p a.errors, a.same?, a.valid?, AppRecord.abstract?
