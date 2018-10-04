# frozen_string_literal: true

require 'error'
require 'format'

module Limit
  class Clause
    attr_reader :count, :offset

    def initialize(count_raw, offset_raw)
      @count = parse(count_raw)
      @offset = parse(offset_raw)
    end

    private

    def parse(raw)
      return unless raw

      if raw['A_Const']
        val = raw['A_Const']['val']

        if val['Integer']
          val['Integer']['ival']
        elsif val['Null']
          nil
        else
          raise TodoError.new(Limit::Clause, raw)
        end

      elsif raw['ColumnRef']
        raw['ColumnRef']['fields'].first['String']['str']

      else
        raise TodoError.new(Limit::Clause, raw)
      end
    end
  end
end
