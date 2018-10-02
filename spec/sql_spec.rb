# frozen_string_literal: true

require 'sql'
require 'default'

# def stmt2(s, opts = {})
#   puts '------------------'
#   sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
#   require 'pp'
#   pp sql.statements.first.stmt
#   sql.statements.first.to_s
# end

# RSpec.describe Sql, '#to_s' do
#   context 'FOOBAR :tcl_semicolon => :same_line' do
#     subject { stmt2(%{
# WITH bar AS (
#   SELECT date
# )
# SELECT cola, colb, colc, cold, cole AS column_e
# FROM dw.foo foo
# --JOIN a.bar bar ON foo.id = bar.foo_id
# --JOIN c.baz baz ON baz.id = bar.baz_id
# WHERE cola > 33
# ORDER BY cola, 2 DESC, 3 ASC, 4 NULLS FIRST, column_e NULLS LAST
# ;

# BEGIN;

# -- foobar
# INSERT INTO dw.foo
# VALUES
#   (1, 2, 3);
# }) }
#     it { is_expected.to eq ['cola', 'colb'] }
#   end
# end
