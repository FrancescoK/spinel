# File.foreach(path).first(n), spliced by the parser for a program that
# writes it, and reached through the analysis' rename (desugar_dir_surface).
# CRuby's blockless foreach is a lazy Enumerator, so `first(n)` reads n lines
# and closes the file; the materializing form read the whole file to answer
# them. First(0) opens nothing, as the Enumerator's does.
class File
  def self.__sp_foreach_first(path, n)
    raise ArgumentError, "attempt to take negative size" if n < 0
    out = []
    return out if n == 0
    File.open(path) do |f|
      f.each_line do |line|
        out << line
        break if out.size >= n
      end
    end
    out
  end
end
