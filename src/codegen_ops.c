/* codegen_ops.c -- the emitters behind builtin_ops rows.

   emit_builtin_op looks the call up in the builtin-op table and runs the
   row's emitter. It sits where the receiver families it covers sat in
   emit_call_body, so the chain above it still claims what it claimed. */

#include "codegen_internal.h"
#include "builtin_ops.h"

/* The receiver's C text, emitted once. A row names it as $r, possibly
   more than once; every $r prints the same text, as the arms the rows
   replace did. */
static char *op_recv_text(Compiler *c, const BopCtx *x) {
  if (x->rtext) return strdup(x->rtext);
  Buf r; memset(&r, 0, sizeof r);
  emit_expr(c, x->recv, &r);
  if (!r.p) return strdup("");
  return r.p;
}

/* A row's C text with its placeholders filled in, each where it stands,
   so the C is emitted in the order the arm the row replaces emitted it:
     $r   the receiver, emitted at its first occurrence (or the text the
          caller rendered, x->rtext); a later $r repeats the same text
     $R   the receiver emitted again, for an arm that emitted it twice
     $T   the temp the family took before its arms (emit_builtin_op_tmp)
     $t $u $v $w  temp numbers. The ones a row names are all taken (++g_tmp,
          in that order) before anything is emitted, as the arms took them
     $eN  argument N by emit_expr
     $bN  argument N boxed (emit_boxed)
     $fN  argument N as a double (emit_float_expr)
     $iN  argument N as an sp_int (emit_int_expr)
     $sN  argument N as a String (emit_str_expr)
     $cN  argument N as an sp_Complex (emit_complex_coerce)
     $qN  argument N as an sp_Rational (emit_rat_coerce) */
static int emit_op_template(Compiler *c, const BopCtx *x, Buf *b) {
  static const char tnames[] = "tuvw";
  int tn[4] = { 0, 0, 0, 0 };
  for (int k = 0; k < 4; k++) {
    char pat[3] = { '$', tnames[k], 0 };
    if (strstr(x->op->arg, pat)) tn[k] = ++g_tmp;
  }
  char *r = NULL;
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  for (const char *p = x->op->arg; *p; p++) {
    const char *tk = p[0] == '$' && p[1] ? strchr(tnames, p[1]) : NULL;
    if (p[0] == '$' && p[1] == 'r') {
      if (!r && x->rtext) { r = strdup(x->rtext); buf_puts(b, r); }
      else if (!r) {
        size_t mark = b->len;
        emit_expr(c, x->recv, b);
        r = strndup(b->p ? b->p + mark : "", b->len - mark);
      }
      else buf_puts(b, r);
      p++;
    }
    else if (p[0] == '$' && p[1] == 'T') {
      buf_printf(b, "%d", x->t0);
      p++;
    }
    else if (p[0] == '$' && p[1] == 'R') {
      emit_expr(c, x->recv, b);
      p++;
    }
    else if (tk) {
      buf_printf(b, "%d", tn[tk - tnames]);
      p++;
    }
    else if (p[0] == '$' && p[1] && strchr("ebficqs", p[1]) &&
             p[2] >= '0' && p[2] <= '9' && p[2] - '0' < argc) {
      int a = argv[p[2] - '0'];
      switch (p[1]) {
      case 'e': emit_expr(c, a, b); break;
      case 'b': emit_boxed(c, a, b); break;
      case 'f': emit_float_expr(c, a, b); break;
      case 'i': emit_int_expr(c, a, b); break;
      case 's': emit_str_expr(c, a, b); break;
      case 'c': emit_complex_coerce(c, a, b); break;
      default:  emit_rat_coerce(c, a, b); break;
      }
      p += 2;
    }
    else { char ch[2] = { *p, 0 }; buf_puts(b, ch); }
  }
  free(r);
  return 1;
}

/* Process::Status#success?: the runtime answers -1 for CRuby's nil, when
   the process did not exit normally */
static int emit_op_pstatus_success(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  int t = ++g_tmp;
  buf_printf(b, "({ int _t%d = sp_process_status_success_p((%s)->status);"
                " _t%d < 0 ? sp_box_nil() : sp_box_bool((sp_bool)_t%d); })", t, r, t, t);
  free(r);
  return 1;
}

/* Process::Status#== / #eql? with no operand: false, the receiver still
   evaluated */
static int emit_op_pstatus_eq(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  free(r);
  buf_puts(b, "((void)("); emit_boxed(c, x->recv, b); buf_puts(b, "), (sp_bool)0)");
  return 1;
}

/* --plan-check: the row codegen emitted the call with should be the row
   inference answered it with (the same receiver kind, name and result; a
   row guarded on its first argument stands for its unguarded sibling).
   Inside a view the node is being read as another kind on purpose, so only
   calls emitted at view depth 0 are compared.
     conflict    inference answered from a different row: the two halves
                 decided the call differently
     unrecorded  inference answered without a row (a rule ahead of the
                 lookup, or a codegen-only row whose result is TY_UNKNOWN) */
static void plan_check_observe(Compiler *c, int id, TyKind rt, const BuiltinOp *op) {
  if (view_depth() > 0 || id < 0 || id >= c->node_cap) return;
  const BuiltinOp *inf = c->bop_inf[id];
  if (inf && inf->recv == op->recv && sp_streq(inf->name, op->name) &&
      bop_result(inf, rt) == bop_result(op, rt)) return;
  if (inf)
    fprintf(stderr, "plan-check: conflict: node %d %s#%s: codegen row %d..%d -> %s, inference row %s#%s -> %s\n",
            id, ty_name(rt), op->name, op->argc_min, op->argc_max, ty_name(bop_result(op, rt)),
            ty_name(inf->recv), inf->name, ty_name(bop_result(inf, rt)));
  else
    fprintf(stderr, "plan-check: unrecorded: node %d %s#%s: codegen row %d..%d -> %s, inference answered without a row\n",
            id, ty_name(rt), op->name, op->argc_min, op->argc_max, ty_name(bop_result(op, rt)));
}

static int (*const bop_emitters[BOPE__COUNT])(Compiler *, const BopCtx *, Buf *) = {
  [BOPE_NONE] = NULL,
  [BOPE_TEMPLATE] = emit_op_template,
  [BOPE_PSTATUS_SUCCESS] = emit_op_pstatus_success,
  [BOPE_PSTATUS_EQ] = emit_op_pstatus_eq,
  [BOPE_THREAD_SET_REPORT] = emit_op_thread_set_report,
  [BOPE_THREAD_RAISE] = emit_op_thread_raise,
  [BOPE_THREAD_TLS] = emit_op_thread_tls,
  [BOPE_MUTEX_SLEEP] = emit_op_mutex_sleep,
  [BOPE_CONDVAR_WAIT] = emit_op_condvar_wait,
  [BOPE_QUEUE_PUSH] = emit_op_queue_push,
  [BOPE_QUEUE_POP] = emit_op_queue_pop,
  [BOPE_FIBER_RESUME] = emit_op_fiber_resume,
  [BOPE_FIBER_TRANSFER] = emit_op_fiber_transfer,
  [BOPE_FIBER_RAISE] = emit_op_fiber_raise,
  [BOPE_RATIONAL_ROUND] = emit_op_rational_round,
};

/* an argument's kind, for a row's argument guard */
typedef struct { const Compiler *c; const int *argv; } BopArgs;
static TyKind bop_arg_ntype(const void *ud, int i) {
  const BopArgs *a = ud;
  return comp_ntype(a->c, a->argv[i]);
}

static int emit_builtin_op_ex(Compiler *c, int id, int recv, TyKind rt, const char *name,
                              const char *rtext, int t0, Buf *b) {
  if (recv < 0 || !bop_covers(rt)) return 0;
  int argc;
  const int *argv = call_args(c->nt, id, &argc);
  BopArgs a = { c, argv };
  const BuiltinOp *op = bop_find_arg(rt, name, argc, nt_ref(c->nt, id, "block") >= 0,
                                     bop_arg_ntype, &a);
  if (!op || op->emit == BOPE_NONE || !bop_emitters[op->emit]) return 0;
  BopCtx x = { id, recv, argc, rt, name, op, rtext, t0 };
  if (!bop_emitters[op->emit](c, &x, b)) return 0;
  if (g_plan_check) plan_check_observe(c, id, rt, op);
  return 1;
}

int emit_builtin_op_text(Compiler *c, int id, int recv, TyKind rt, const char *name,
                         const char *rtext, Buf *b) {
  return emit_builtin_op_ex(c, id, recv, rt, name, rtext, 0, b);
}

int emit_builtin_op_tmp(Compiler *c, int id, int recv, TyKind rt, const char *name,
                        int t0, Buf *b) {
  return emit_builtin_op_ex(c, id, recv, rt, name, NULL, t0, b);
}

int emit_builtin_op(Compiler *c, int id, int recv, TyKind rt, const char *name, Buf *b) {
  return emit_builtin_op_ex(c, id, recv, rt, name, NULL, 0, b);
}
