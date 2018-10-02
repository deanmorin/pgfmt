# frozen_string_literal: true

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

  def initialize(raw, opts)
    @raw = raw
    @opts = opts
  end

  def to_s
    kind = KINDS.fetch(@raw['kind'])
    s = case kind
        when :tcl_begin
          options = TclBeginOptions.new(@raw['options']).options
          parts = [Format.sym_to_s(@opts[kind])] + options
          Format.keyword(Format.join_parts(parts), @opts)
        when :tcl_savepoint
          "#{Format.keyword('savepoint', @opts)} #{savepoint_name}"
        when :tcl_release_savepoint, :tcl_rollback_to_savepoint
          "#{Format.sym_to_keyword(@opts[kind], @opts)} #{savepoint_name}"
        else
          Format.sym_to_keyword(@opts[kind], @opts)
        end
    Format.add_semicolon(s, @opts, :tcl_semicolon)
  end

  private

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
    when READ_WRITE then 'read write'
    when READ_ONLY  then 'read only'
    when nil        then nil
    else
      raise "Need additional handling for #{val}"
    end
  end

  def deferrable
    opt = @options.find { |x| x['defname'] == 'transaction_deferrable' }
    return unless opt

    val = opt['arg']['A_Const']['val']['Integer']['ival']
    case val
    when NOT_DEFERRABLE then 'not deferrable'
    when DEFERRABLE     then 'deferrable'
    when nil            then nil
    else
      raise "Need additional handling for #{val}"
    end
  end
end
