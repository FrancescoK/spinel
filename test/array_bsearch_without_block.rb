block_result = [0, 1, 3, 4].bsearch { |value| value >= 2 }
enumerator = [0, 1, 3, 4].bsearch
p block_result
p enumerator.class
p enumerator.size
p enumerator.next
p enumerator.next
enumerator.rewind
p enumerator.each { |value| value >= 2 }
