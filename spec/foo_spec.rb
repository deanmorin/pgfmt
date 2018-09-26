# frozen_string_literal: true

require 'foo'
require 'default'

def stmt2(s, opts={})
  puts '------------------'
  sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
  sql
end

RSpec.describe Sql, '#to_s' do
  context ':tcl_semicolon => :same_line' do
    subject { stmt2(%{
WITH bar AS (
  SELECT date
)
SELECT cola, colb
FROM dw.foo foo
JOIN a.bar bar ON foo.id = bar.foo_id
--JOIN c.baz baz ON baz.id = bar.baz_id
;

BEGIN;

-- foobar
INSERT INTO dw.foo
VALUES
  (1, 2, 3);
}) }
    it { is_expected.to eq "BEGIN;" }
  end
end
