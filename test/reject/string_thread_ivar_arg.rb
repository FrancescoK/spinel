# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-thread-string
class C
  def run
    @s = +"a"
    Thread.new(@s) { |t| t << "!" }.join
    p @s
  end
end
C.new.run
