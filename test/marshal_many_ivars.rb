# A class with more ivars than a fixed table held: Marshal.dump writes
# each set ivar and leaves out the ones nothing has set, past the 64th too.
class Wide
  def initialize
    @v0 = 0
    @v1 = 1
    @v2 = 2
    @v4 = 4
    @v5 = 5
    @v6 = 6
    @v7 = 7
    @v8 = 8
    @v9 = 9
    @v11 = 11
    @v12 = 12
    @v13 = 13
    @v14 = 14
    @v15 = 15
    @v16 = 16
    @v18 = 18
    @v19 = 19
    @v20 = 20
    @v21 = 21
    @v22 = 22
    @v23 = 23
    @v25 = 25
    @v26 = 26
    @v27 = 27
    @v28 = 28
    @v29 = 29
    @v30 = 30
    @v32 = 32
    @v33 = 33
    @v34 = 34
    @v35 = 35
    @v36 = 36
    @v37 = 37
    @v39 = 39
    @v40 = 40
    @v41 = 41
    @v42 = 42
    @v43 = 43
    @v44 = 44
    @v46 = 46
    @v47 = 47
    @v48 = 48
    @v49 = 49
    @v50 = 50
    @v51 = 51
    @v53 = 53
    @v54 = 54
    @v55 = 55
    @v56 = 56
    @v57 = 57
    @v58 = 58
    @v60 = 60
    @v61 = 61
    @v62 = 62
    @v63 = 63
    @v64 = 64
    @v65 = 65
    @v67 = 67
    @v68 = 68
    @v69 = 69
  end
  def fill = (@v3 = 3; @v66 = 66)
end
w = Wide.new
d = Marshal.dump(w)
p d.bytesize
p Marshal.load(d).instance_variables.size
w.fill
p Marshal.load(Marshal.dump(w)).instance_variables.size
