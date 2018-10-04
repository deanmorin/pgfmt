# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (where)' do
  WHERE_TEMPLATE = 'SELECT column_a, column_b, column_c AS foo FROM a_table WHERE'

  def stmt(s, opts = {})
    sql = Sql.new("#{WHERE_TEMPLATE} #{s};", DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s.scan(/WHERE[^;]*/).first.chomp
  end

  context 'column = column' do
    subject { stmt('a = b') }
    it { is_expected.to eq 'WHERE a = b' }
  end

  context 'column = constant' do
    subject { stmt('a = 1') }
    it { is_expected.to eq 'WHERE a = 1' }
  end

  context 'constant = column' do
    subject { stmt('1 = a') }
    it { is_expected.to eq 'WHERE 1 = a' }
  end

  context 'var = constant' do
    subject { stmt('@a = 1') }
    it { is_expected.to eq 'WHERE @a = 1' }
  end

  context 'sublink = constant' do
    subject { stmt('(SELECT 1) = 1') }
    it { expect { subject }.to raise_error TodoError }
  end

  context 'column < constant' do
    subject { stmt('a < 1') }
    it { is_expected.to eq 'WHERE a < 1' }
  end

  context 'column <= constant' do
    subject { stmt('a <= 1') }
    it { is_expected.to eq 'WHERE a <= 1' }
  end

  context 'column > constant' do
    subject { stmt('a > 1') }
    it { is_expected.to eq 'WHERE a > 1' }
  end

  context 'column >= constant' do
    subject { stmt('a >= 1') }
    it { is_expected.to eq 'WHERE a >= 1' }
  end

  context 'not_equal: :ansi' do
    subject { stmt('a != 1', not_equal: :ansi) }
    it { is_expected.to eq 'WHERE a <> 1' }
  end

  context 'not_equal: :c_style' do
    subject { stmt('a <> 1', not_equal: :c_style) }
    it { is_expected.to eq 'WHERE a != 1' }
  end
end
