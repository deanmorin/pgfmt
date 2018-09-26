# frozen_string_literal: true

require 'foo'

def stmt(s, opts = {})
  sql = Sql.new(s, DEFAULT_OPTS.merge(opts))
  sql.statements.first.to_s
end

RSpec.describe Tcl, '#to_s' do
  context ':tcl_semicolon => :same_line' do
    subject { stmt('BEGIN', tcl_semicolon: :same_line) }
    it { is_expected.to eq 'BEGIN;' }
  end

  context ':tcl_semicolon => :new_line' do
    subject { stmt('BEGIN', tcl_semicolon: :new_line) }
    it { is_expected.to eq "BEGIN\n;" }
  end

  context ':keyword_case => :uppercase' do
    subject { stmt('begin;', keyword_case: :uppercase) }
    it { is_expected.to eq 'BEGIN;' }
  end

  context ':keyword_case => :lowercase' do
    subject { stmt('BEGIN;', keyword_case: :lowercase) }
    it { is_expected.to eq 'begin;' }
  end

  context ':tcl_begin => :begin' do
    subject { stmt('BEGIN TRANSACTION;', tcl_begin: :begin) }
    it { is_expected.to eq 'BEGIN;' }
  end

  context ':tcl_begin => :begin_transaction' do
    subject { stmt('BEGIN WORK;', tcl_begin: :begin_transaction) }
    it { is_expected.to eq 'BEGIN TRANSACTION;' }
  end

  context ':tcl_begin => :begin_work' do
    subject { stmt('START TRANSACTION;', tcl_begin: :begin_work) }
    it { is_expected.to eq 'BEGIN WORK;' }
  end

  context ':tcl_begin => :begin_work' do
    subject { stmt('BEGIN;', tcl_begin: :start_transaction) }
    it { is_expected.to eq 'START TRANSACTION;' }
  end

  context ':tcl_commit => :commit' do
    subject { stmt('COMMIT TRANSACTION;', tcl_commit: :commit) }
    it { is_expected.to eq 'COMMIT;' }
  end

  context ':tcl_commit => :commit_transaction' do
    subject { stmt('COMMIT WORK;', tcl_commit: :commit_transaction) }
    it { is_expected.to eq 'COMMIT TRANSACTION;' }
  end

  context ':tcl_commit => :commit_work' do
    subject { stmt('COMMIT;', tcl_commit: :commit_work) }
    it { is_expected.to eq 'COMMIT WORK;' }
  end

  context ':tcl_commit => :end' do
    subject { stmt('END TRANSACTION;', tcl_commit: :end) }
    it { is_expected.to eq 'END;' }
  end

  context ':tcl_commit => :end_transaction' do
    subject { stmt('END WORK;', tcl_commit: :end_transaction) }
    it { is_expected.to eq 'END TRANSACTION;' }
  end

  context ':tcl_commit => :end_work' do
    subject { stmt('END;', tcl_commit: :end_work) }
    it { is_expected.to eq 'END WORK;' }
  end

  context ':tcl_rollback => :rollback' do
    subject { stmt('ROLLBACK TRANSACTION;', tcl_rollback: :rollback) }
    it { is_expected.to eq 'ROLLBACK;' }
  end

  context ':tcl_rollback => :rollback_transaction' do
    subject { stmt('ROLLBACK WORK;', tcl_rollback: :rollback_transaction) }
    it { is_expected.to eq 'ROLLBACK TRANSACTION;' }
  end

  context ':tcl_rollback => :rollback_work' do
    subject { stmt('ROLLBACK;', tcl_rollback: :rollback_work) }
    it { is_expected.to eq 'ROLLBACK WORK;' }
  end

  context 'includes transaction isolation' do
    subject { stmt('BEGIN ISOLATION LEVEL SERIALIZABLE;') }
    it { is_expected.to eq 'BEGIN ISOLATION LEVEL SERIALIZABLE;' }
  end

  context 'includes read write' do
    subject { stmt('BEGIN READ WRITE;') }
    it { is_expected.to eq 'BEGIN READ WRITE;' }
  end

  context 'includes read only' do
    subject { stmt('BEGIN READ ONLY;') }
    it { is_expected.to eq 'BEGIN READ ONLY;' }
  end

  context 'includes deferrable' do
    subject { stmt('BEGIN DEFERRABLE;') }
    it { is_expected.to eq 'BEGIN DEFERRABLE;' }
  end

  context 'includes not deferrable' do
    subject { stmt('BEGIN NOT DEFERRABLE;') }
    it { is_expected.to eq 'BEGIN NOT DEFERRABLE;' }
  end

  context 'includes multiple transaction modes' do
    subject { stmt('BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY NOT DEFERRABLE;') }
    it { is_expected.to eq 'BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY NOT DEFERRABLE;' }
  end

  context 'includes multiple transaction modes out of order' do
    subject { stmt('BEGIN NOT DEFERRABLE READ ONLY ISOLATION LEVEL REPEATABLE READ;') }
    it { is_expected.to eq 'BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY NOT DEFERRABLE;' }
  end

  context 'savepoint' do
    subject { stmt('SAVEPOINT foo;') }
    it { is_expected.to eq 'SAVEPOINT foo;' }
  end

  context ':tcl_release_savepoint => :release_savepoint' do
    subject { stmt('RELEASE foo;', tcl_release_savepoint: :release_savepoint) }
    it { is_expected.to eq 'RELEASE SAVEPOINT foo;' }
  end

  context ':tcl_release_savepoint => :release' do
    subject { stmt('RELEASE SAVEPOINT foo;', tcl_release_savepoint: :release) }
    it { is_expected.to eq 'RELEASE foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_to_savepoint' do
    subject { stmt('ROLLBACK TO foo;', tcl_rollback_to_savepoint: :rollback_to_savepoint) }
    it { is_expected.to eq 'ROLLBACK TO SAVEPOINT foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_to' do
    subject { stmt('ROLLBACK TO SAVEPOINT foo;', tcl_rollback_to_savepoint: :rollback_to) }
    it { is_expected.to eq 'ROLLBACK TO foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_transaction_to' do
    subject { stmt('ROLLBACK TO foo;', tcl_rollback_to_savepoint: :rollback_transaction_to) }
    it { is_expected.to eq 'ROLLBACK TRANSACTION TO foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_work_to' do
    subject { stmt('ROLLBACK TO foo;', tcl_rollback_to_savepoint: :rollback_work_to) }
    it { is_expected.to eq 'ROLLBACK WORK TO foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_transaction_to_savepoint' do
    subject { stmt('ROLLBACK TO foo;', tcl_rollback_to_savepoint: :rollback_transaction_to_savepoint) }
    it { is_expected.to eq 'ROLLBACK TRANSACTION TO SAVEPOINT foo;' }
  end

  context ':tcl_rollback_to_savepoint => :rollback_work_to_savepoint' do
    subject { stmt('ROLLBACK TO foo;', tcl_rollback_to_savepoint: :rollback_work_to_savepoint) }
    it { is_expected.to eq 'ROLLBACK WORK TO SAVEPOINT foo;' }
  end
end
