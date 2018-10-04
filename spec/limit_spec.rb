# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (limit)' do
  def stmt(s, opts = {})
    sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s
  end

  context 'count' do
    subject { stmt('SELECT * FROM a_table LIMIT 1;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\nLIMIT 1\n;" }
  end

  context 'offset' do
    subject { stmt('SELECT * FROM a_table OFFSET 10;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\nOFFSET 10\n;" }
  end

  context 'count & offset' do
    subject { stmt('SELECT * FROM a_table LIMIT 1 OFFSET 10;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\nLIMIT 1 OFFSET 10\n;" }
  end

  context 'null count' do
    subject { stmt('SELECT * FROM a_table LIMIT NULL;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n;" }
  end

  context 'null offset' do
    subject { stmt('SELECT * FROM a_table OFFSET NULL;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n;" }
  end

  context 'all count' do
    subject { stmt('SELECT * FROM a_table LIMIT ALL;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\n;" }
  end

  context 'refs' do
    subject { stmt('SELECT * FROM a_table LIMIT foo OFFSET bar;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\nLIMIT foo OFFSET bar\n;" }
  end

  context 'alternate syntax' do
    subject { stmt('SELECT * FROM a_table OFFSET 10 ROW FETCH FIRST 1 ROW ONLY;') }
    it { is_expected.to eq "SELECT *\nFROM a_table\nLIMIT 1 OFFSET 10\n;" }
  end

  context 'count expr' do
    subject { stmt('SELECT * FROM a_table LIMIT 1 + 1;') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'offset expr' do
    subject { stmt('SELECT * FROM a_table OFFSET 1 + 1;') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'count var' do
    subject { stmt('SELECT * FROM a_table LIMIT @foo;') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'offset var' do
    subject { stmt('SELECT * FROM a_table OFFSET @foo;') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'count sublink' do
    subject { stmt('SELECT * FROM a_table LIMIT (SELECT 1);') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'offset sublink' do
    subject { stmt('SELECT * FROM a_table OFFSET (SELECT 1);') }
    it { expect { subject }.to raise_error TodoError }
  end
end
