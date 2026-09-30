# A named reference may stand after the flags and width of a format
# directive (`%02<cents>d`, `%0<n>5d`, `%-5{x}`), and a named reference after an
# unnumbered one names itself in the error.
p format("%<sign>s%02<cents>d", sign: "-", cents: 5)
p format("%-6<w>s|", w: "ab")
p format("%+<n>d %08.3<f>f", n: 3, f: 3.14159)
p format("%<cents>02d", cents: 5)
p format("%-5{x}|%{y}", x: "a", y: 7)
p format("%0<n>5d", n: 1)
p format("%<a>s and %<b>s", a: 1, b: 2)
h = { v: 42 }
p format("%05<v>d", h)
begin; format("%s %<a>s", 1, a: 2); rescue ArgumentError => e; p e.message; end
begin; format("%<a>s %s", { a: 2 }); rescue ArgumentError => e; p e.message; end
