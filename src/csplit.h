#ifndef SPINEL_CSPLIT_H
#define SPINEL_CSPLIT_H
#include <stddef.h>

/* Split the preprocessed unit at pre_path into out_dir/sp_split.h and
   nparts part files (their paths written to part_paths). Returns nparts, or
   -1 when the unit holds something the splitter does not read, in which
   case the caller compiles the single unit. See csplit.c. */
int c_split(const char *pre_path, const char *out_dir, int nparts,
            char (*part_paths)[4096], char *hdr_path, size_t hdr_sz);

/* The --incremental split (c_split_units). A label names an over-cap
   group (`x_<group>_<s>`), and a group is up to 191 characters. */
#define CS_LABEL_MAX 256
typedef struct {
  size_t unit_bytes;      /* --unit-bytes, bytes of marker-free text per unit */
  int keep_markers;       /* hash with the line markers (-g / --debug) */
  const char *drop_decl;  /* SPINEL_UNIT_DROP_DECL test hook, or NULL */
} CSplitOpts;
typedef struct {
  char label[CS_LABEL_MAX];
  char path[4096];
  char hash[65];
  int is_rt;              /* 1: includes sp_rt.h only; key excludes program_hash */
  size_t bytes;           /* marker-free bytes */
  char *groups;           /* for units.txt / --cache-stats; malloc'd */
} CSplitUnit;
typedef struct {
  CSplitUnit *units; int n;              /* in link order */
  char rt_hash[65], program_hash[65];
  char rt_header[4096], program_header[4096];
} CSplitResult;
/* Split the preprocessed unit at pre_path, cut at the `#pragma spinel unit`
   lines codegen wrote, into out_dir: sp_rt.h (+ sp_sys_rt*.h), sp_program.h
   (+ sp_sys_prog*.h), unit_<hash>.c per unit and units.txt. 0, or -1 when
   the unit holds something this reader does not read (the caller then
   compiles the single unit). */
int c_split_units(const char *pre_path, const char *out_dir, const CSplitOpts *opts, CSplitResult *res);
/* 1 when the file at path begins as the units.txt c_split_units writes
   (its rt_hash line): a directory holding one is a unit set of spinel's,
   not a units.txt of someone else's that happens to be there. */
int c_split_units_manifest(const char *path);
void c_split_result_free(CSplitResult *res);

#endif
