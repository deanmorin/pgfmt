# frozen_string_literal: true

require 'error'
require 'format'

module OrderBy
  class Clause
    attr_reader :columns

    def initialize(raw)
      @columns = raw.map { |x| Column.new(x['SortBy']) }
    end
  end

  class Column
    attr_reader :name, :direction, :nulls

    DIRECTIONS = {
      0 => :asc,
      1 => :asc,
      2 => :desc,
    }.freeze

    NULLS = {
      0 => :default,
      1 => :nulls_first,
      2 => :nulls_last,
    }.freeze

    def initialize(raw)
      @name = parse_name(raw)
      @direction = DIRECTIONS.fetch(raw['sortby_dir'])
      nulls = NULLS.fetch(raw['sortby_nulls'])
      @nulls = if nulls == :default
                 @direction == :asc ? :nulls_last : :nulls_first
               else
                 nulls
               end
    end

    def uses_default_nulls_option?
      (direction == :asc && nulls == :nulls_last) ||
        (direction == :desc && nulls == :nulls_first)
    end

    private

    def parse_name(raw)
      if raw['node']['ColumnRef']
        raw['node']['ColumnRef']['fields'].first['String']['str']
      elsif raw['node']['A_Const']
        raw['node']['A_Const']['val']['Integer']['ival'].to_s
      else
        raise UnknownOptionError.new(OrderBy::Column, raw)
      end
    end
  end
end
