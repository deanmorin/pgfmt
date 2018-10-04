# frozen_string_literal: true

require 'error'

module Where
  class Clause
    attr_reader :lexpr, :operator, :rexpr

    def initialize(raw)
      @lexpr = parse_expr(raw['A_Expr']['lexpr'])
      @operator = raw['A_Expr']['name'].first['String']['str']
      @rexpr = parse_expr(raw['A_Expr']['rexpr'])
    end

    def parse_expr(raw)
      if raw['A_Const']
        raw['A_Const']['val']['Integer']['ival']

      elsif raw['ColumnRef']
        raw['ColumnRef']['fields'].first['String']['str']

      elsif raw['A_Expr'] && raw['A_Expr']['name'].first['String']['str']
        "@#{raw['A_Expr']['rexpr']['ColumnRef']['fields'].first['String']['str']}"

      else
        raise TodoError.new(Where::Clause, raw)
      end
    end
  end
end
