# frozen_string_literal: true

require 'pg_query'
require 'comment'
require 'dml'
require 'error'
require 'format'
require 'tcl'

class Sql
  def initialize(sql, opts)
    @sql = PgQuery.parse(sql.strip)
    @opts = opts
  end

  def statements
    @sql.tree.map do |x|
      stmt = x['RawStmt']['stmt']

      if stmt['TransactionStmt']
        tcl = Tcl.new(stmt['TransactionStmt'])
        Format::Tcl.new(tcl, @opts)

      elsif stmt['SelectStmt']
        select = Dml::Select.new(stmt['SelectStmt'])
        Format::Select.new(select, @opts)

      else
        raise TodoError.new(Sql, stmt)
      end
    end
  end

  def comments
    CommentParser.parse(@sql.query)
  end
end
