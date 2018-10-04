# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (target)' do
  def stmt(s, opts = {})
    sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s
  end

  context 'foo' do
    subject { stmt('SELECT * FROM a_table;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n;" }
  end

  context 'foo' do
    subject { stmt('SELECT a, b, c FROM a_table;') }
    it { is_expected.to eq "SELECT a,\n       b,\n       c\nFROM a_table\n;" }
  end

  context 'foo' do
    subject { stmt('SELECT a AS foo FROM a_table;') }
    it { is_expected.to eq "SELECT a AS foo\nFROM a_table\n;" }
  end
end
