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

class Select
  def initialize(raw, opts)
    @stmt = raw['stmt']['SelectStmt']
    @opts = opts
  end

  def target_list
    @stmt['targetList']
  end

  def fromClause
    @stmt['fromClause']
  end

  def RangeVar(raw)
    rv = raw['RangeVar']
    schemaname = rv['schemaname']
    relname = rv['relname']
  end
            # [{"RangeVar"=>
            #    {"schemaname"=>"dw",
            #     "relname"=>"foo",
            #     "inh"=>true,
            #     "relpersistence"=>"p",
            #     "location"=>53}}],
  #
  #           [{"JoinExpr"=>
       #        {"jointype"=>1,
       #         "larg"=>
       #          {"RangeVar"=>
       #            {"schemaname"=>"dw",
       #             "relname"=>"foo",
       #             "inh"=>true,
       #             "relpersistence"=>"p",
       #             "alias"=>{"Alias"=>{"aliasname"=>"foo"}},
       #             "location"=>53}},
       #         "rarg"=>
       #          {"RangeVar"=>
       #            {"schemaname"=>"a",
       #             "relname"=>"bar",
       #             "inh"=>true,
       #             "relpersistence"=>"p",
       #             "alias"=>{"Alias"=>{"aliasname"=>"bar"}},
       #             "location"=>74}},
       #         "quals"=>
       #          {"A_Expr"=>
       #            {"kind"=>0,
       #             "name"=>[{"String"=>{"str"=>"="}}],
       #             "lexpr"=>
       #              {"ColumnRef"=>
       #                {"fields"=>
       #                  [{"String"=>{"str"=>"foo"}},
       #                   {"String"=>{"str"=>"id"}}],
       #                 "location"=>87}},
       #             "rexpr"=>
       #              {"ColumnRef"=>
       #                {"fields"=>
       #                  [{"String"=>{"str"=>"bar"}},
       #                   {"String"=>{"str"=>"foo_id"}}],
       #                 "location"=>96}},
       #             "location"=>94}}}}],
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
