# frozen_string_literal: true

DEFAULT_OPTS = {
  # general_style:               :right_aligned,
  general_style:               :left_aligned,
  # general_style:               :heading,
  soft_line_limit:             100,
  keyword_case:                :uppercase,
  indent_size:                 2,
  tcl_semicolon:               :same_line,
  tcl_begin:                   :begin,
  tcl_commit:                  :commit,
  tcl_rollback:                :rollback,
  tcl_release_savepoint:       :release_savepoint,
  tcl_rollback_to_savepoint:   :rollback_to_savepoint,
  sql_semicolon:               :new_line,
  group_by_style:              :one_line,
  order_by_style:              :one_line,
  order_by_implicit_direction: true,
  order_by_implicit_nulls:     true,
}.freeze
