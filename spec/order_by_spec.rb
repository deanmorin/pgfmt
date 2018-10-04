# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (order_by)' do
  ORDER_BY_TEMPLATE = 'SELECT a, b, c AS foo FROM a_table ORDER BY'

  def stmt(s, opts = {})
    sql = Sql.new("#{ORDER_BY_TEMPLATE} #{s};", DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s.scan(/ORDER BY[^;]*/).first.chomp
  end

  context 'column name, column number, column alias' do
    subject { stmt('a, 2, foo') }
    it { is_expected.to eq 'ORDER BY a, 2, foo' }
  end

  context 'order_by_implicit_direction: true' do
    subject { stmt('a ASC, b DESC', order_by_implicit_direction: true) }
    it { is_expected.to eq 'ORDER BY a, b DESC' }
  end

  context 'order_by_implicit_direction: false' do
    subject { stmt('a, b DESC', order_by_implicit_direction: false) }
    it { is_expected.to eq 'ORDER BY a ASC, b DESC' }
  end

  context 'order_by_implicit_nulls: true' do
    subject { stmt('a, b DESC', order_by_implicit_nulls: true) }
    it { is_expected.to eq 'ORDER BY a, b DESC' }
  end

  context 'order_by_implicit_nulls: true with non-defaults' do
    subject { stmt('a NULLS FIRST, b DESC NULLS LAST', order_by_implicit_nulls: true) }
    it { is_expected.to eq 'ORDER BY a NULLS FIRST, b DESC NULLS LAST' }
  end

  context 'order_by_implicit_nulls: false' do
    subject { stmt('a, b DESC', order_by_implicit_nulls: false) }
    it { is_expected.to eq 'ORDER BY a NULLS LAST, b DESC NULLS FIRST' }
  end

  context 'order_by_implicit_nulls: false' do
    subject { stmt('a, b DESC', order_by_implicit_nulls: false) }
    it { is_expected.to eq 'ORDER BY a NULLS LAST, b DESC NULLS FIRST' }
  end

  context 'order_by_style: :one_line' do
    subject do
      stmt('a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST',
           order_by_style: :one_line,
           soft_line_limit: 20,
           order_by_implicit_direction: false,
           order_by_implicit_nulls: false)
    end
    it { is_expected.to eq 'ORDER BY a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST' }
  end

  context 'order_by_style: :prefer_one_line short' do
    subject do
      stmt('a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST',
           order_by_style: :prefer_one_line,
           soft_line_limit: 1000,
           order_by_implicit_direction: false,
           order_by_implicit_nulls: false)
    end
    it { is_expected.to eq 'ORDER BY a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST' }
  end

  context 'order_by_style: :prefer_one_line long' do
    subject do
      stmt('a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST',
           order_by_style: :prefer_one_line,
           soft_line_limit: 20,
           order_by_implicit_direction: false,
           order_by_implicit_nulls: false)
    end
    it do
      is_expected.to eq "ORDER BY a DESC NULLS FIRST,\n" \
                        "         b DESC NULLS FIRST,\n" \
                        '         c DESC NULLS FIRST'
    end
  end

  context 'order_by_style: :multi_line' do
    subject do
      stmt('a DESC NULLS FIRST, b DESC NULLS FIRST, c DESC NULLS FIRST',
           order_by_style: :multi_line,
           soft_line_limit: 1000,
           order_by_implicit_direction: false,
           order_by_implicit_nulls: false)
    end
    it do
      is_expected.to eq "ORDER BY a DESC NULLS FIRST,\n" \
                        "         b DESC NULLS FIRST,\n" \
                        '         c DESC NULLS FIRST'
    end
  end

  context 'general_style: :left_aligned' do
    subject { stmt('a, b, c', general_style: :left_aligned, order_by_style: :multi_line) }
    it { is_expected.to eq "ORDER BY a,\n         b,\n         c" }
  end

  context 'general_style: :heading' do
    subject { stmt('a, b, c', general_style: :heading) }
    it { is_expected.to eq "ORDER BY\n  a, b, c" }
  end
end
