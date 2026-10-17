# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# A native method's :cstring answer is the callee's own buffer copied onto
# the String heap at the call site, a new String each call: under
# --share-strings it is read as fresh with no native_share declaration, so
# a value the program shares and changes may hold it (the nokogiri
# package's Document#version, which has no .share.rb).
module N
  ffi_source <<~C
    struct my_doc_s { int n; };
    static void my_doc_scan(void *p) { (void)p; }
    my_doc *my_doc_new(sp_int cls_id) {
      my_doc *d = (my_doc *)sp_gc_alloc(sizeof(my_doc), NULL, my_doc_scan);
      (void)cls_id; d->n = 0;
      return d;
    }
    const char *my_doc_version(my_doc *d) {
      static char buf[16];
      snprintf(buf, sizeof buf, "1.%d", d->n++);
      return buf;
    }
  C
  native_struct "Doc", "my_doc"
  native_new [], "my_doc_new"
  native_method :__version, [], :cstring, "my_doc_version"
end
class Document
  def initialize = @ref = N::Doc.new
  def version
    v = @ref.__version
    v == "" ? nil : v
  end
end
d = Document.new
a = d.version
b = a
b << "!"
c = d.version
p a, b, c, a.equal?(b), a.equal?(c)
