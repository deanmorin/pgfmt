# frozen_string_literal: true

# require 'error'
require 'where'

module From
  class Clause
    attr_reader :schema, :name, :alias

    def initialize(raw)
      from = raw.first

      if from['RangeVar']
        r = Relation.new(from)
        @schema = r.schema
        @name = r.name
        @alias = r.alias

      elsif from['JoinExpr']
        Join.new(from['JoinExpr'])
      end
    end
  end

  class Join
    attr_reader :type, :left, :right, :on

    TYPES = {
      # TODO cross join also 0
      0 => :inner,
      1 => :left,
      2 => :full_outer,
      3 => :right,
    }.freeze

    def initialize(raw)
      @type = TYPES.fetch(raw['jointype'])
      @left = Relation.new(raw['larg'])
      @right = Relation.new(raw['rarg'])
      @on = On.new(raw['quals'])
    end
  end

  class Relation
    attr_reader :schema, :name, :alias

    def initialize(raw)
      var = raw['RangeVar']
      @schema = var['schemaname']
      @name = var['relname']
      var['alias'] && @alias = var['alias']['Alias']['aliasname']
    end
  end

  class On < Where::Clause
  end
end
