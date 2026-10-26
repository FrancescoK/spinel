class Calc
  prechigh
    nonassoc UMINUS
    left '*' '/'
    left '+' '-'
  preclow
rule
  target: exp { result = val[0] }
  exp: exp '+' exp { result = val[0] + val[2] }
     | exp '-' exp { result = val[0] - val[2] }
     | exp '*' exp { result = val[0] * val[2] }
     | exp '/' exp { result = val[0] / val[2] }
     | '(' exp ')' { result = val[1] }
     | '-' NUMBER = UMINUS { result = -val[1] }
     | NUMBER
end
---- inner
  def parse(str)
    @q = []
    until str.empty?
      case str
      when /\A\s+/
      when /\A\d+/
        number = $&
        @q.push [:NUMBER, Integer(number)]
      when /\A.|\n/o
        s = $&
        @q.push [s, s]
      end
      str = $'
    end
    @q.push [false, '$end']
    do_parse
  end
  def next_token
    @q.shift
  end
