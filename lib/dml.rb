# frozen_string_literal: true

require 'format'
require 'from'
require 'group_by'
require 'limit'
require 'order_by'
require 'target'
require 'where'

module Dml
  class Select
    attr_reader :raw, :target_list, :from, :where, :group_by, :order_by, :limit
    def initialize(raw)
      @raw = raw
      @target_list = Target::List.new(@raw['targetList'])
      @from = From::Clause.new(raw['fromClause'])
      raw['whereClause'] && @where = Where::Clause.new(raw['whereClause'])
      raw['groupClause'] && @group_by = GroupBy::Clause.new(raw['groupClause'])
      raw['sortClause']  && @order_by = OrderBy::Clause.new(raw['sortClause'])
      @limit = Limit::Clause.new(raw['limitCount'], raw['limitOffset'])
    end
  end
end
