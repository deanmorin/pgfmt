# frozen_string_literal: true

require 'error'

module Target
  class List
    attr_reader :columns

    def initialize(raw)
      @columns = raw.map { |x| Column.new(x['ResTarget']) }
    end
  end

  class Column
    attr_reader :name, :alias

    def initialize(raw)
      @alias = raw['name']

      field = raw['val']['ColumnRef']['fields'].first
      @name = if field['A_Star']
                '*'
              elsif field['String']
                field['String']['str']
              else
                raise TodoError.new(Target::Column, raw)
              end
    end
  end
end
