# frozen_string_literal: true

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
    @stmt = raw['stmt']['TransactionStmt']
    @opts = opts
  end

  def to_s
    kind = KINDS.fetch(@stmt['kind'])
    s = case kind
        when :tcl_begin
          options = TclBeginOptions.new(@stmt['options']).options
          parts = [symbol_to_string(@opts[kind])] + options
          set_case(parts.compact.join(' '))
        when :tcl_savepoint
          "#{set_case('savepoint')} #{savepoint_name}"
        when :tcl_release_savepoint, :tcl_rollback_to_savepoint
          "#{set_case(symbol_to_string(@opts[kind]))} #{savepoint_name}"
        else
          set_case(symbol_to_string(@opts[kind]))
        end
    add_semicolon(s)
  end

  private

  def set_case(s)
    if @opts[:keyword_case] == :uppercase
      s.upcase
    else
      s.downcase
    end
  end

  def symbol_to_string(symbol)
    symbol.to_s.tr('_', ' ')
  end

  def add_semicolon(s)
    case @opts[:tcl_semicolon]
    when :same_line
      s + ';'
    when :new_line
      s + "\n;"
    end
  end

  def savepoint_name
    @stmt['options'].first['DefElem']['arg']['String']['str']
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
    when READ_WRITE
      'read write'
    when READ_ONLY
      'read only'
    when nil
      nil
    else
      raise "Need additional handling for #{val}"
    end
  end

  def deferrable
    opt = @options.find { |x| x['defname'] == 'transaction_deferrable' }
    return unless opt

    val = opt['arg']['A_Const']['val']['Integer']['ival']
    case val
    when NOT_DEFERRABLE
      'not deferrable'
    when DEFERRABLE
      'deferrable'
    when nil
      nil
    else
      raise "Need additional handling for #{val}"
    end
  end
end
