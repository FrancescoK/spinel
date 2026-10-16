# StringScanner's share declarations, which the parser reads after
# strscan.rb only under --share-strings (see native_share in the native
# binding DSL, and stringio.share.rb for the kinds).
module StringScannerPackage
  native_struct "StringScanner"   # the class the declarations below are for
  # #[] answers a new String, a copy of the capture (sc_substr), or nil: one
  # no other name holds. The other readers are left undeclared: scan, check
  # and the _until forms keep their answer as #matched too, and peek, rest,
  # pre_match and post_match answer the one empty String for an empty
  # result.
  native_share "[]", [:int], "fresh"
end
