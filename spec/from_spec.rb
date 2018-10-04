# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (from)' do
  def stmt(s, opts = {})
    sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s
  end

  context 'foo' do
    subject { stmt('SELECT * FROM a_table;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n;" }
  end

  context 'schema' do
    subject { stmt('SELECT * FROM foo.a_table;') }
    it { is_expected.to eq "SELECT *\nFROM foo.a_table\n;" }
  end

  context 'alias' do
    subject { stmt('SELECT * FROM a_table a;') }
    it { is_expected.to eq "SELECT *\nFROM a_table a\n;" }
  end

  context 'from' do
    subject { stmt('SELECT * FROM a_table a INNER JOIN b_table b ON a.foo = b.foo;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n     JOIN b_table b ON a.foo = b.foo\n;" }
  end
end
