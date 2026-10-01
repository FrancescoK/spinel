/* builtin_names.h -- families of builtin method, class, and global names,
   plus numeric literal tags, that the compiler asks about in many places:
   `[] () call`, `is_a? kind_of? instance_of?`,
   ... Each predicate answers whether a name is one of its family; the
   family's names are listed once, in builtin_names.c, where every site that
   spelled the chain out now asks. A predicate compares the name with each of
   its family in turn, as the chains did (sp_streq counts the work).
   Near-families (a set one name larger or smaller) are
   different questions and keep their own spelling. */
#ifndef SPINEL_BUILTIN_NAMES_H
#define SPINEL_BUILTIN_NAMES_H

int is_zip_name(const char *n);       /* zip: tuple-yielding iteration */
int is_call_alias(const char *n);     /* call () []: a Proc/Method's invocation */
int is_kind_query(const char *n);     /* is_a? kind_of? instance_of? */
int is_round_family(const char *n);   /* round ceil floor truncate */
int is_push_alias(const char *n);     /* push << append */
int is_bit_op(const char *n);         /* & | ^ */
int is_basic_arith(const char *n);    /* + - * / (is_arith_op adds % and **) */
int is_add_sub_mul(const char *n);    /* + - * */
int is_int_bit_op(const char *n);     /* & | ^ << >>: Integer's bitwise operators */
int is_object_root(const char *n);    /* Object Kernel BasicObject: the classes every object has */
int is_send_family(const char *n);    /* send __send__ public_send */
int is_name_reader(const char *n);    /* name to_s inspect: a Class's or Module's name */
int is_tap_alias(const char *n);      /* tap then yield_self */
int is_quantifier(const char *n);     /* all? any? none? one? */
int is_set_op(const char *n);         /* & intersection | union - difference */
int is_combination_family(const char *n);  /* combination permutation repeated_combination repeated_permutation */
int is_visibility_name(const char *n);     /* private protected public */
int is_select_bang(const char *n);    /* select! filter! keep_if reject! delete_if: the in-place filters */
int is_each_walk(const char *n);      /* each each_entry reverse_each */
int is_index_query(const char *n);    /* find_index index rindex */
int is_self_copy(const char *n);      /* freeze dup clone itself: the receiver, or a copy of it */
int is_int_step(const char *n);       /* times upto downto: Integer's counting iterators */
int is_equality_name(const char *n);  /* equal? eql? == */
int is_bits_query(const char *n);     /* allbits? anybits? nobits? */
int is_count_alias(const char *n);    /* length size count */
int is_class_eval_family(const char *n);  /* class_eval module_eval class_exec module_exec */
int is_eval_exec_family(const char *n);   /* class/module/instance eval and exec */
int is_key_query(const char *n);      /* key? has_key? include? member?: Hash/ENV membership aliases */
int is_range_membership(const char *n); /* cover? include? member? ===: Range membership predicates */
int is_each_walk_or_with_index(const char *n); /* each each_entry reverse_each each_with_index */
int is_call_or_yield(const char *n);  /* call () [] yield: is_call_alias's names and yield */
int is_proc_invoke(const char *n);    /* call () [] yield ===: every name that invokes a Proc */
int is_quantifier_or_count(const char *n);  /* all? any? none? one? count: is_quantifier's names and count */
int is_push_unshift(const char *n);   /* << push append unshift: is_push_alias's names and unshift */
int is_len_alias(const char *n);      /* length size */
int is_str_each_iter(const char *n);  /* each_char each_line each_byte each_codepoint: String's element iterators */
int is_diverging_call(const char *n); /* raise fail throw exit exit! abort: a Kernel call that never returns */
int is_block_loop_method(const char *n); /* times each upto downto step loop each_with_index: a block run an unbounded number of times */

int is_each_window(const char *n); /* each_cons each_slice: consecutive or disjoint element windows */
int is_reduce_alias(const char *n); /* inject reduce: Enumerable reduction aliases */
int is_minmax_query(const char *n); /* min max: extrema queries */
int is_endpoint_query(const char *n); /* first last: collection or Range endpoints */
int is_map_alias(const char *n); /* map collect: Enumerable transformation aliases */
int is_instance_eval_family(const char *n); /* instance_eval instance_exec */
int is_find_alias(const char *n); /* find detect: Enumerable search aliases */

int is_text_conversion(const char *n); /* inspect to_s */
int is_slice_alias(const char *n); /* [] slice */
int is_shift_op(const char *n); /* << >> */
int is_copy_alias(const char *n); /* clone dup */
int is_hash_merge_bang(const char *n); /* merge! update */
int is_membership_alias(const char *n); /* include? member? */
int is_eql_or_equal(const char *n); /* eql? equal? */
int is_substitution(const char *n); /* gsub sub */
int is_element_at_alias(const char *n); /* [] at */
int is_map_bang_alias(const char *n); /* collect! map! */
int is_each_or_pair(const char *n); /* each each_pair */
int is_proc_constructor(const char *n); /* lambda proc */

int is_inspect_print(const char *n); /* p pp */
int is_then_alias(const char *n); /* then yield_self */
int is_intersection_alias(const char *n); /* & intersection */
int is_add_sub(const char *n); /* + - */
int is_store_alias(const char *n); /* []= store */
int is_pop_shift(const char *n); /* pop shift */
int is_prepend_alias(const char *n); /* prepend unshift */
int is_text_print(const char *n); /* print puts */
int is_union_alias(const char *n); /* union | */
int is_eq_or_ne(const char *n); /* != == */
int is_size_or_count(const char *n); /* count size */
int is_bounded_int_step(const char *n); /* downto upto */

int is_indexed_each(const char *n); /* each_index each_with_index */
int is_to_array_alias(const char *n); /* entries to_a */
int is_string_index(const char *n); /* index rindex */
int is_modulo_alias(const char *n); /* % modulo */
int is_append_concat(const char *n); /* << concat */
int is_socket_address(const char *n); /* addr peeraddr */
int is_attr_writer_family(const char *n); /* attr_accessor attr_writer */
int is_take_drop(const char *n); /* drop take */
int is_byte_codepoint_each(const char *n); /* each_byte each_codepoint */
int is_with_index_alias(const char *n); /* each_with_index with_index */
int is_freeze_family(const char *n); /* freeze frozen? */
int is_nonblock_io(const char *n); /* read_nonblock write_nonblock */

int is_mul_or_pow(const char *n); /* * ** */
int is_unary_sign(const char *n); /* +@ -@ */
int is_casecmp_family(const char *n); /* casecmp casecmp? */
int is_hash_key_value_each(const char *n); /* each_key each_value */
int is_encoding_mutator(const char *n); /* encode! force_encoding */
int is_range_end_reader(const char *n); /* end last */
int is_raise_alias(const char *n); /* fail raise */
int is_first_or_take(const char *n); /* first take */
int is_lazy_force(const char *n); /* force to_a */
int is_local_time(const char *n); /* getlocal localtime */
int is_line_read(const char *n); /* gets readline */
int is_open_constructor(const char *n); /* new open */

int is_succ_alias(const char *n); /* next succ */
int is_path_reader(const char *n); /* path to_path */
int is_io_position(const char *n); /* pos tell */
int is_sort_family(const char *n); /* sort sort! */
int is_io_write(const char *n); /* syswrite write */
int is_to_integer(const char *n); /* to_i to_int */
int is_match_operator(const char *n); /* !~ =~ */
int is_div_or_mod(const char *n); /* % / */
int is_add_or_mul(const char *n); /* * + */
int is_push_operator(const char *n); /* << push */
int is_eq_or_eql(const char *n); /* == eql? */
int is_element_access(const char *n); /* [] []= */

int is_current_method(const char *n); /* __callee__ __method__ */
int is_hash_constructor(const char *n); /* __hash_new_default new */
int is_attr_reader_family(const char *n); /* attr_accessor attr_reader */
int is_range_bound_reader(const char *n); /* begin end */
int is_directory_entries(const char *n); /* children entries */
int is_exception_full_message(const char *n); /* detailed_message full_message */
int is_each_or_index(const char *n); /* each each_with_index */
int is_with_object_alias(const char *n); /* each_with_object with_object */
int is_exist_alias(const char *n); /* exist? exists? */
int is_select_alias(const char *n); /* filter select */
int is_format_alias(const char *n); /* format sprintf */
int is_initialize_family(const char *n); /* initialize initialize_copy */

int is_iso8601_alias(const char *n); /* iso8601 xmlschema */
int is_exception_message(const char *n); /* message to_s */
int is_socket_pair_alias(const char *n); /* pair socketpair */
int is_partition_family(const char *n); /* partition rpartition */
int is_to_rational(const char *n); /* rationalize to_r */
int is_rectangular_alias(const char *n); /* rect rectangular */
int is_numeric_conversion(const char *n); /* to_f to_i */
int is_remainder_family(const char *n); /* % modulo remainder */
int is_select_reject(const char *n); /* filter reject select */
int is_bit_set_operator(const char *n); /* & - | */
int is_find_or_take_while(const char *n); /* detect find take_while */
int is_named_set_operator(const char *n); /* difference intersection union */

int is_select_reject_bang(const char *n); /* filter! reject! select! */
int is_element_pick(const char *n); /* first last sample */
int is_extrema_family(const char *n); /* max min minmax */
int is_io_wait(const char *n); /* wait_priority wait_readable wait_writable */
int is_match_family(const char *n); /* !~ =~ match match? */
int is_integer_iteration(const char *n); /* downto step times upto */
int is_visibility_or_module_function(const char *n); /* module_function private protected public */
int is_string_position_mutator(const char *n); /* []= clear insert setbyte slice! */
int is_array_push_family(const char *n); /* << append prepend push unshift */

int is_io_class_name(const char *n); /* File IO */
int is_immediate_class_name(const char *n); /* FalseClass NilClass TrueClass */
int is_object_base_name(const char *n); /* BasicObject Object */
int is_boolean_class_name(const char *n); /* FalseClass TrueClass */
int is_numeric_literal_tag(const char *n); /* Float Int */
int is_standard_output_global(const char *n); /* $stderr $stdout */
int is_program_name_global(const char *n); /* $0 $PROGRAM_NAME */
int is_range_or_time_class(const char *n); /* Range Time */
int is_numeric_class_name(const char *n); /* Float Integer */
int is_queue_class_name(const char *n); /* Queue SizedQueue */
int is_array_or_object_class(const char *n); /* Array Object */
int is_array_hash_or_object_class(const char *n); /* Array Hash Object */

int is_integer_class_name(const char *n); /* Fixnum Integer */

int is_ivar_access(const char *n);   /* instance_variable_get instance_variable_set */

#endif
