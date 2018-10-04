# frozen_string_literal: true

module Format
  module Helpers
    def keyword(s)
      if @opts[:keyword_case] == :uppercase
        s.upcase
      else
        s.downcase
      end
    end

    def sym_to_s(symbol)
      symbol.to_s.tr('_', ' ')
    end

    def sym_to_keyword(symbol)
      keyword(sym_to_s(symbol))
    end

    def join_clauses(clauses)
      clauses.compact.join("\n")
    end

    def join_parts(parts)
      parts.compact.join(' ')
    end

    def join_columns(columns, style_opt, indent)
      case @opts[style_opt]

      when :one_line
        columns.join(', ')

      when :multi_line
        columns.join(",\n#{indent}")

      when :prefer_one_line
        if columns.join(', ').size <= @opts[:soft_line_limit]
          columns.join(', ')
        else
          columns.join(",\n#{indent}")
        end
      end
    end

    def just_clause_keyword(s)
      section_just = if @opts[:general_style] == :right_aligned
                       @opts[:indent_size].size - 1
                     else
                       0
                     end
      s.rjust(section_just, ' ')
    end

    def add_semicolon(s, semicolon_opt)
      case @opts[semicolon_opt]
      when :same_line then s + ';'
      when :new_line  then s + "\n;"
      end
    end

    def operator(op)
      op == '<>' && @opts[:not_equal] == :c_style ? '!=' : op
    end
  end

  class Select
    include Format::Helpers

    def initialize(select, opts)
      @select = select
      @opts = opts

      indent =
        case @opts[:general_style]
        when :right_aligned then (select.group_by || select.order_by) ? 9 : 7
        when :left_aligned then 7 # TODO: foo
        when :heading then @opts[:indent_size]
        end

      @opts[:indent_size] = indent

      initial_separator =
        case @opts[:general_style]
        when :right_aligned then ' '
        when :left_aligned then ' '
        when :heading then "\n#{' ' * indent}"
        end

      @opts[:indent] = ' ' * indent
      @opts[:initial_separator] = initial_separator
    end

    def to_s
      clauses = [target_list, from, where, group_by, order_by, limit]
      joined = join_clauses(clauses)
      add_semicolon(joined, :sql_semicolon)
    end

    def target_list
      "#{just_clause_keyword('SELECT')}#{@opts[:initial_separator]}" +
        @select.target_list.columns.map { |x| target_column(x) }.join(",\n#{@opts[:indent]}")
    end

    def target_column(column)
      as = column.alias ? " AS #{column.alias}" : ''
      column.name + as
    end

    def from
      Format::From.new(@select.from, @opts).to_s
    end

    def where
      @select.where && Format::Where.new(@select.where, @opts).to_s
    end

    def group_by
      @select.group_by && Format::GroupBy.new(@select.group_by, @opts).to_s
    end

    def order_by
      @select.order_by && Format::OrderBy.new(@select.order_by, @opts).to_s
    end

    def limit
      @select.limit && Format::Limit.new(@select.limit, @opts).to_s
    end
  end

  class From
    include Format::Helpers

    def initialize(from, opts)
      @from = from
      @opts = opts
    end

    def to_s
      full_name = @from.schema ? "#{@from.schema}.#{@from.name}" : @from.name
      "#{just_clause_keyword('FROM')}#{@opts[:initial_separator]}" +
        join_parts([full_name, @from.alias])
    end
  end

  class Where
    include Format::Helpers

    def initialize(where, opts)
      @where = where
      @opts = opts
    end

    def to_s
      "#{just_clause_keyword('WHERE')}#{@opts[:initial_separator]}" \
        "#{@where.lexpr} #{operator(@where.operator)} #{@where.rexpr}"
    end
  end

  class GroupBy
    include Format::Helpers

    def initialize(group_by, opts)
      @group_by = group_by
      @opts = opts
    end

    def to_s
      case @opts[:general_style]
      when :right_aligned then right_aligned
      when :left_aligned  then left_aligned
      when :heading       then heading
      end
    end

    def right_aligned
      indent = ' ' * @opts[:indent_size]
      cols = @group_by.columns.map(&:name)

      s = "#{just_clause_keyword('GROUP BY')} "
      s + join_columns(cols, :group_by_style, indent)
    end

    def left_aligned
      indent = ' ' * 9 # 'ORDER BY '.size
      cols = @group_by.columns.map(&:name)

      "GROUP BY #{join_columns(cols, :group_by_style, indent)}"
    end

    def heading
      indent = ' ' * @opts[:indent_size]
      cols = @group_by.columns.map(&:name)

      "GROUP BY\n#{indent}#{join_columns(cols, :group_by_style, indent)}"
    end
  end

  class OrderBy
    include Format::Helpers

    def initialize(order_by, opts)
      @order_by = order_by
      @opts = opts
    end

    def to_s
      s = just_clause_keyword('ORDER BY')
      s += @opts[:initial_separator]
      s + join_columns(columns, :order_by_style, ' ' * @opts[:indent_size])
    end

    def columns
      @order_by.columns.map do |column|
        name = column.name
        direction =
          if column.direction == :asc && @opts[:order_by_implicit_direction]
            nil
          else
            sym_to_keyword(column.direction)
          end
        nulls =
          if column.uses_default_nulls_option? && @opts[:order_by_implicit_nulls]
            nil
          else
            sym_to_keyword(column.nulls)
          end
        join_parts([name, direction, nulls])
      end
    end
  end

  class Limit
    include Format::Helpers

    def initialize(limit, opts)
      @limit = limit
      @opts = opts
    end

    def to_s
      parts = [@limit.count ? "LIMIT #{@limit.count}" : nil,
               @limit.offset ? "OFFSET #{@limit.offset}" : nil]
      joined = join_parts(parts)
      joined.empty? ? nil : joined
    end
  end

  class Tcl
    include Format::Helpers

    def initialize(tcl, opts)
      @tcl = tcl
      @opts = opts
    end

    def to_s
      kind = @tcl.kind
      s = case kind
          when :tcl_begin
            parts = [@opts[kind]] + @tcl.begin_options
            parts = parts.map { |x| sym_to_s(x) }
            keyword(join_parts(parts))
          when :tcl_savepoint
            "#{keyword('savepoint')} #{@tcl.savepoint_name}"
          when :tcl_release_savepoint, :tcl_rollback_to_savepoint
            "#{sym_to_keyword(@opts[kind])} #{@tcl.savepoint_name}"
          else
            sym_to_keyword(@opts[kind])
          end
      add_semicolon(s, :tcl_semicolon)
    end
  end
end
