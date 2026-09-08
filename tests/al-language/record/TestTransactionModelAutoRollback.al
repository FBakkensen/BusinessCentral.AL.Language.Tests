// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/testfield/testfield-method
//   and https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testisolation-property
// Scope: in-scope
// Fixtures used: ALT Base (60007); shared Assert (60021)
//
// TestIsolationRollbackScope (60897) pins that under TestIsolation = Codeunit (the
// default), a row one [Test] writes without committing IS still visible to the next
// [Test] on the same codeunit instance. This pins the override: a [Test] procedure
// carrying [TransactionModel(TransactionModel::AutoRollback)] gets its OWN writes
// rolled back the moment it finishes — pass or fail — regardless of the codeunit's
// overall TestIsolation mode. The attribute is a per-TEST-METHOD override, not a
// codeunit-wide setting.
//
// Tests 04-08 pin the other half of the attribute: an explicit Commit() while an
// AutoRollback test method is in force. The platform refuses it outright
// ("Tests cannot call the Commit function if TransactionModel property is set to
// AutoRollback."), the refusal follows the executing TEST METHOD rather than the
// frame the Commit() sits in, and [CommitBehavior(CommitBehavior::Ignore)] exempts
// it while [CommitBehavior(CommitBehavior::Error)] does not outrank it. Codeunit
// 60881 ("Test Commit Behavior Attr") pins what those two behaviours do on their
// own, under the default transaction model.
//
// Test01-Test03 are declaration-ordered and share a codeunit, mirroring
// TestIsolationRollbackScope's own convention.
//   Test01 (AutoRollback): writes a uniquely-keyed row, does not Commit.
//   Test02 (no attribute — plain AutoCommit default): asks whether Test01's row
//     survived. It must NOT: TransactionModel::AutoRollback is what rolled it back,
//     not TestIsolation = Codeunit rolling back between every test (which
//     TestIsolationRollbackScope already showed does not happen on its own).
//   Test02 then writes its OWN uniquely-keyed row (no attribute, no Commit) to prove
//     the DEFAULT behaviour is unaffected by the previous test's attribute — that row
//     DOES survive into Test03, exactly like TestIsolationRollbackScope's own pair.
//   Test03 (no attribute): confirms Test02's row survived.
//
// BC also rolls an AutoRollback test back on an unhandled failure, not only on a
// normal return (observable in the platform's own test-execution loop: the same
// Session.Rollback() call sits in both the success switch and the surrounding
// catch(Exception) block). That half is not pinned here — a corpus test whose own
// [Test] procedure is *expected* to report FAIL is not expressible without making
// this suite permanently non-green, unlike every other corpus codeunit.
codeunit 60899 "Test TxModel AutoRollback"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ExplicitCommitNotAllowedErr: Label 'Tests cannot call the Commit function if TransactionModel property is set to AutoRollback.', Locked = true;
        CommitProhibitedFragmentTxt: Label 'Commit is prohibited in the current scope', Locked = true;
        UnrelatedErr: Label 'unrelated error, nothing to do with the row above', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure Test01_AutoRollbackWritesARowWithoutCommitting()
    var
        Base: Record "ALT Base";
    begin
        if Base.Get(60899001) then
            Base.Delete();

        Base.Init();
        Base."Entry No." := 60899001;
        Base."Name" := 'txmodel-autorollback-probe';
        Base.Insert();

        Assert.IsTrue(Base.Get(60899001), 'The probe row must exist inside the test that wrote it.');
    end;

    [Test]
    procedure Test02_PriorAutoRollbackRowDidNotSurvive_ThenWritesItsOwnDefaultRow()
    var
        Base: Record "ALT Base";
    begin
        Assert.IsFalse(
            Base.Get(60899001),
            'TransactionModel::AutoRollback on the PREVIOUS test must roll its own uncommitted ' +
            'write back the moment that test finished, regardless of TestIsolation = Codeunit ' +
            '(which on its own would have left the row visible here — see TestIsolationRollbackScope).');

        if Base.Get(60899002) then
            Base.Delete();

        Base.Init();
        Base."Entry No." := 60899002;
        Base."Name" := 'txmodel-default-probe';
        Base.Insert();
    end;

    [Test]
    procedure Test03_DefaultModelRowFromPriorTestDidSurvive()
    var
        Base: Record "ALT Base";
    begin
        Assert.IsTrue(
            Base.Get(60899002),
            'A [Test] with no TransactionModel override is unaffected by the previous AutoRollback ' +
            'test: its own uncommitted write still survives into the next test on the same ' +
            'codeunit, exactly as TestIsolationRollbackScope pins for the codeunit-wide default.');

        Base.Delete();
    end;

    // ── Explicit Commit() under TransactionModel::AutoRollback ────────────────
    //
    // Tests 04-08 pin the platform's refusal of an explicit Commit() while an
    // AutoRollback test method is in force, and how that refusal interacts with
    // [CommitBehavior(...)] (whose own rules are pinned by Codeunit 60881,
    // "Test Commit Behavior Attr"). The refusal is session state, not a lexical
    // property of the Commit() statement: Test05 issues it from a callee that
    // carries no attribute of its own.
    //
    // Test06 is the control twin. It is the same shape under
    // TransactionModel::AutoCommit, and it is what makes Tests 04/05 statements
    // about the ATTRIBUTE rather than about calling Commit() in a test at all —
    // Codeunit 60881's whole suite already commits from unattributed [Test]
    // methods, so an unattributed test is not refused.

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure Test04_AutoRollbackRefusesAnExplicitCommit()
    var
        Base: Record "ALT Base";
    begin
        Base.Init();
        Base."Entry No." := 60899004;
        Base."Name" := 'txmodel-commit-refusal';
        Base.Insert();

        asserterror Commit();

        Assert.ExpectedError(ExplicitCommitNotAllowedErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure Test05_AutoRollbackRefusalReachesAnUnattributedCallee()
    begin
        // The Commit() is one frame down, in a procedure carrying no attribute of
        // its own: the refusal follows the executing TEST METHOD's transaction
        // model, not the shape of the frame the Commit() sits in.
        asserterror CommitFromAnUnattributedCallee();

        Assert.ExpectedError(ExplicitCommitNotAllowedErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure Test06_AutoCommitAllowsAnExplicitCommit()
    var
        Base: Record "ALT Base";
    begin
        if Base.Get(60899006) then
            Base.Delete();

        Base.Init();
        Base."Entry No." := 60899006;
        Base."Name" := 'txmodel-autocommit-probe';
        Base.Insert();
        // Not refused, and a real commit: the row survives the unrelated error below.
        Commit();

        asserterror Error(UnrelatedErr);
        Assert.ExpectedError(UnrelatedErr);

        Assert.IsTrue(Base.Get(60899006),
            'Under TransactionModel::AutoCommit the explicit Commit() is allowed and is an ordinary commit, so the row must survive the unrelated error.');

        // Leave nothing committed behind for the next test on this codeunit.
        Base.Delete();
        Commit();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure Test07_CommitBehaviorIgnoreExemptsTheAutoRollbackRefusal()
    var
        Base: Record "ALT Base";
    begin
        // [CommitBehavior(CommitBehavior::Ignore)] on the callee: the Commit() is
        // neither refused (no error escapes the call) nor performed (the boundary
        // does not move, so the unrelated error below still undoes the Insert).
        InsertAndCommitIgnoringCommits(60899007);

        asserterror Error(UnrelatedErr);
        Assert.ExpectedError(UnrelatedErr);

        Assert.IsFalse(Base.Get(60899007),
            'An ignored Commit() does not move the rollback boundary, so the unrelated error must still undo the Insert.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure Test08_AutoRollbackRefusalOutranksCommitBehaviorError()
    var
        LastError: Text;
    begin
        // Both guards apply. Which message the caller sees says which one the
        // platform evaluates first.
        asserterror CommitUnderErrorBehavior();
        LastError := GetLastErrorText();

        Assert.ExpectedError(ExplicitCommitNotAllowedErr);
        Assert.AreEqual(0, StrPos(LastError, CommitProhibitedFragmentTxt),
            'The AutoRollback refusal is what the caller sees; the [CommitBehavior(CommitBehavior::Error)] message must not be the one raised.');
    end;

    local procedure CommitFromAnUnattributedCallee()
    begin
        Commit();
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure InsertAndCommitIgnoringCommits(EntryNo: Integer)
    var
        Base: Record "ALT Base";
    begin
        Base.Init();
        Base."Entry No." := EntryNo;
        Base."Name" := 'txmodel-ignore-probe';
        Base.Insert();
        Commit();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CommitUnderErrorBehavior()
    begin
        Commit();
    end;
}
