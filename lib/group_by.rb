# frozen_string_literal: true

require 'error'
require 'format'

module GroupBy
  class Clause
    attr_reader :columns

    def initialize(raw)
      @columns = raw.map { |x| Column.new(x) }
    end
  end

  class Column
    attr_reader :name

    def initialize(raw)
      @name = parse_name(raw)
    end

    private

    def parse_name(raw)
      if raw['ColumnRef']
        raw['ColumnRef']['fields'].first['String']['str']
      elsif raw['A_Const']
        raw['A_Const']['val']['Integer']['ival'].to_s
      else
        raise UnknownOptionError.new(GroupBy::Column, raw)
      end
    end
  end
end
