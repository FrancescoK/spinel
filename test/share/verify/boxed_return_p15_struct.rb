S = Struct.new(:x, :y)
src = "s".dup
st = S.new(src, 1)
arr = [st.x, st.x]
arr[0] << "#"
p arr, src, st.x
