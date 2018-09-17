require 'foo'

DEFAULT_OPTS = {
  :keyword_case              => :uppercase,
  :tcl_semicolon             => :same_line,
  :tcl_begin                 => :begin,
  :tcl_commit                => :commit,
  :tcl_rollback              => :rollback,
  :tcl_release_savepoint     => :release_savepoint,
  :tcl_rollback_to_savepoint => :rollback_to_savepoint,
}

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
