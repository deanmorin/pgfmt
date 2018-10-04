# frozen_string_literal: true

require 'sql'

RSpec.describe Sql, '#to_s (group_by)' do
  GROUP_BY_TEMPLATE = 'SELECT column_a, column_b, column_c AS foo FROM a_table GROUP BY'

  def stmt(s, opts = {})
    sql = Sql.new("#{GROUP_BY_TEMPLATE} #{s};", DEFAULT_OPTS.merge(opts))
    sql.statements.first.to_s.scan(/GROUP BY[^;]*/).first.chomp
  end

  context 'column name, column number, column alias' do
    subject { stmt('column_a, 2, foo') }
    it { is_expected.to eq 'GROUP BY column_a, 2, foo' }
  end

  context 'group_by_style: :one_line' do
    subject do
      stmt('column_a, column_b, column_c',
           group_by_style: :one_line,
           soft_line_limit: 3)
    end
    it { is_expected.to eq 'GROUP BY column_a, column_b, column_c' }
  end

  context 'group_by_style: :prefer_one_line short' do
    subject do
      stmt('column_a, column_b, column_c',
           group_by_style: :prefer_one_line,
           soft_line_limit: 1000)
    end
    it { is_expected.to eq 'GROUP BY column_a, column_b, column_c' }
  end

  context 'group_by_style: :prefer_one_line short' do
    subject do
      stmt('column_a, column_b, column_c',
           group_by_style: :prefer_one_line,
           soft_line_limit: 3)
    end
    it { is_expected.to eq "GROUP BY column_a,\n         column_b,\n         column_c" }
  end

  context 'group_by_style: :multi_line' do
    subject do
      stmt('column_a, column_b, column_c',
           group_by_style: :multi_line,
           soft_line_limit: 1000)
    end
    it { is_expected.to eq "GROUP BY column_a,\n         column_b,\n         column_c" }
  end

  context 'general_style: :left_aligned' do
    subject { stmt('a, b, c', general_style: :left_aligned, group_by_style: :multi_line) }
    it { is_expected.to eq "GROUP BY a,\n         b,\n         c" }
  end

  context 'general_style: :heading' do
    subject { stmt('a, b, c', general_style: :heading) }
    it { is_expected.to eq "GROUP BY\n  a, b, c" }
  end
end
