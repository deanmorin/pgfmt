# frozen_string_literal: true

require 'error'
require 'format'

class Tcl
  KINDS = {
    0 => :tcl_begin,
    1 => :tcl_begin,
    2 => :tcl_commit,
    3 => :tcl_rollback,
    4 => :tcl_savepoint,
    5 => :tcl_release_savepoint,
    6 => :tcl_rollback_to_savepoint,
  }.freeze

  def initialize(raw)
    @raw = raw
  end

  def kind
    KINDS.fetch(@raw['kind'])
  end

  def begin_options
    TclBeginOptions.new(@raw['options']).options
  end

  def savepoint_name
    @raw['options'].first['DefElem']['arg']['String']['str']
  end
end

class TclBeginOptions
  READ_WRITE = 0
  READ_ONLY = 1
  NOT_DEFERRABLE = 0
  DEFERRABLE = 1

  def initialize(options)
    options ||= []
    @options = options.map { |x| x['DefElem'] }
  end

  def options
    [isolation, read_only, deferrable].compact
  end

  private

  def isolation
    opt = @options.find { |x| x['defname'] == 'transaction_isolation' }
    return unless opt

    val = opt['arg']['A_Const']['val']['String']['str']
    "isolation level #{val}"
  end

  def read_only
    opt = @options.find { |x| x['defname'] == 'transaction_read_only' }
    return unless opt

    val = opt['arg']['A_Const']['val']['Integer']['ival']
    case val
    when READ_WRITE then :read_write
    when READ_ONLY  then :read_only
    when nil        then nil
    else
      raise UnknownOptionError.new(GroupBy::TclBeginOptions, val)
    end
  end

  def deferrable
    opt = @options.find { |x| x['defname'] == 'transaction_deferrable' }
    return unless opt

    val = opt['arg']['A_Const']['val']['Integer']['ival']
    case val
    when NOT_DEFERRABLE then :not_deferrable
    when DEFERRABLE     then :deferrable
    when nil            then nil
    else
      raise UnknownOptionError.new(GroupBy::TclBeginOptions, val)
    end
  end
end
