# frozen_string_literal: true

require 'pg_query'
require 'comment'
require 'tcl'

class Sql
  def initialize(sql, opts)
    @sql = PgQuery.parse(sql.strip)
    @opts = opts
  end

  def raw
    @sql.query
  end

  def statements
    @sql.tree.map do |x|
      type = x['RawStmt']['stmt'].keys.first
      if type == 'TransactionStmt'
        Tcl.new(x['RawStmt'], @opts)
      elsif type == 'SelectStmt'
        Select.new(x['RawStmt'], @opts)
        # https://www.tech-recipes.com/rx/55356/dml-ddl-dcl-and-tcl-statements-in-sql-with-examples/
      else
        x['RawStmt']['stmt']
      end
    end
  end

  def comments
    CommentParser.parse(@sql.query)
  end
end

class TargetList
  def initialize(raw)
    @raw = raw
  end

  def columns
    @raw.map { |x| x['ResTarget']['val']['ColumnRef']['fields'].first['String']['str'] }
  end
end

class Select
  attr_reader :stmt
  def initialize(raw, opts)
    @stmt = raw['stmt']['SelectStmt']
    @opts = opts
  end

  def to_s
    case @opts[:general_style]
    when :right_aligned
      indent = '       '
      section_just = 8 # TODO: adjust based on sections
      # 6
      initial_separator = ' '
    when :left_aligned
      indent = '       '
      section_just = 0
      initial_separator = ' '
    when :heading
      indent = ' ' * @opts[:indent_size]
      section_just = 0
      initial_separator = "\n#{indent}"
    end
    s = "#{'SELECT'.rjust(section_just, ' ')}#{initial_separator}"
    s += target_list.join(",\n#{indent}")
    s += "\n"
    s += "#{'FROM'.rjust(section_just, ' ')}#{initial_separator}"
    s += "#{from_clause.schema}.#{from_clause.name} #{from_clause.alias}"
    s += "\n"
    s += "#{'WHERE'.rjust(section_just, ' ')}#{initial_separator}"
    s += "#{where_clause.lexpr} #{where_clause.operator} #{where_clause.rexpr}"
    s += "\n"
    s += "#{'ORDER BY'.rjust(section_just, ' ')}#{initial_separator}"
    s += order_by.join(",\n#{indent}")
    s
  end

  def target_list
    TargetList.new(@stmt['targetList']).columns
  end

  def from_clause
    From.new(@stmt['fromClause'])
  end

  def where_clause
    Where.new(@stmt['whereClause'])
  end

  def order_by
    OrderBy.new(@stmt['sortClause'])
  end
end

class From
  attr_reader :schema, :name, :alias

  def initialize(raw)
    from = raw.first['RangeVar']
    @schema = from['schemaname']
    @name = from['relname']
    @alias = from['alias']['Alias']['aliasname']
  end
end

class Joins
  def initialize(raw, opts)
    @stmt = raw['JoinExpr']
    @opts = opts
    @foo = join
  end

  def join
    type = @stmt['jointype']
    larg = @stmt['larg']
    rarg = @stmt['rarg']
    quals = @stmt['quals']
  end
end

class Join
  attr_reader :type, :left, :right, :on

  TYPES = {
    # TODO cross join also 0
    0 => :join_inner,
    1 => :join_left,
    2 => :join_full_outer,
    3 => :join_right,
  }.freeze

  def initialize(raw)
    @type = TYPES.fetch(raw['jointype'])
    @left = Relation.new(raw['larg'])
    @left = Relation.new(raw['rarg'])
    @on = On.new(raw['quals'])
  end
end

class Relation
  attr_reader :schema, :name, :alias

  def initialize(raw)
    @schema = raw['RangeVar']['schemaname']
    @name = raw['RangeVar']['relname']
    @alias = raw['RangeVar']['alias']['Alias']['aliasname']
  end
end

class On
  attr_reader :foo

  KINDS = {
    0 => :todo,
  }.freeze

  def initialize(raw)
    @foo = 'bar'
  end
end

class Where
  attr_reader :lexpr, :operator, :rexpr

  def initialize(raw)
    @lexpr = raw['A_Expr']['lexpr']['ColumnRef']['fields'].first['String']['str']
    @operator = raw['A_Expr']['name'].first['String']['str']
    @rexpr = raw['A_Expr']['rexpr']['A_Const']['val']['Integer']['ival']
  end
end

def where(raw)
  {
    lexpr: raw['A_Expr']['lexpr']['ColumnRef']['fields'].first['String']['str'],
    operator: raw['A_Expr']['name'].first['String']['str'],
    rexpr: raw['A_Expr']['rexpr']['A_Const']['val']['Integer']['ival'],
  }
end

class OrderBy
  attr_reader :columns

  def initialize(raw)
    @columns = raw.map { |x| OrderByColumn.new(x['SortBy']) }
  end
end

class OrderByColumn
  attr_reader :name, :direction, :nulls

  DIRECTIONS = {
    0 => :default,
    1 => :asc,
    2 => :desc,
  }.freeze

  NULLS = {
    0 => :default,
    1 => :first,
    2 => :last,
  }.freeze

  def initialize(raw)
    @name = if raw['node']['ColumnRef']
              raw['node']['ColumnRef']['fields'].first['String']['str']
            else
              raw['node']['A_Const']['val']['Integer']['ival'].to_s
            end
    @direction = DIRECTIONS.fetch(raw['sortby_dir'])
    @nulls = NULLS.fetch(raw['sortby_nulls'])
  end
end

foo

# module OrderBy
#   DIRECTIONS = {
#     0 => :default,
#     1 => :asc,
#     2 => :desc,
#   }.freeze

#   NULLS = {
#     0 => :default,
#     1 => :first,
#     2 => :last,
#   }.freeze

#   def make(raw)
#     raw.map { |x| column(x['SortBy']) }
#   end

#   def column(raw)
#     {
#       name: if raw['node']['ColumnRef']
#               raw['node']['ColumnRef']['fields'].first['String']['str']
#             else
#               raw['node']['A_Const']['val']['Integer']['ival'].to_s
#             end,
#       direction: DIRECTIONS.fetch(raw['sortby_dir']),
#       nulls: NULLS.fetch(raw['sortby_nulls']),
#     }
#   end
# end
