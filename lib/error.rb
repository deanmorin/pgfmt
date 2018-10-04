# frozen_string_literal: true

class TodoError < StandardError
  def initialize(klass, raw)
    require 'pp'
    msg = " This type of SQL is not a known option for #{klass}:\n#{raw.pretty_inspect}"
    # msg = " This type of SQL is not yet supported for #{klass}: #{raw}"
    super(msg)
  end
end

class UnknownOptionError < StandardError
  def initialize(klass, raw)
    msg = " This type of SQL is not a known option for #{klass}: #{raw}"
    super(msg)
  end
end
