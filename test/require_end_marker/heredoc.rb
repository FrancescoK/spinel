# a line reading __END__ inside a heredoc is text, not the marker
HEREDOC_TEXT = <<~T
  first
__END__
  last
T
def heredoc_text = HEREDOC_TEXT.lines.map(&:strip).join(",")
