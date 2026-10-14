#ifndef SPINEL_CEXT_RECORDER_H
#define SPINEL_CEXT_RECORDER_H
void sp_cext_record_begin(const char *);
void sp_cext_record_finish(void);
void sp_cext_record_external(const char *) __attribute__((noreturn));
#endif
