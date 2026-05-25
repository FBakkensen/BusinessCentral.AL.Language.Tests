// Contract tests for temporary table behaviour:
//   - TableType = Temporary (always in-memory, no DB backing)
//   - AutoIncrement is NOT assigned on temp (no DB sequence)
//   - Copy(false) creates an independent buffer
//   - pass-by-value isolates; pass-by-ref (var) shares
codeunit 60198 "Test Temp Table Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── TableType = Temporary ──────────────────────────────────────────────────

    [Test]
    procedure TempOnly_IsTemporary_AlwaysTrue()
    var
        T: Record "ALT Temp Only";
    begin
        Initialize();
        Assert.IsTrue(T.IsTemporary(), 'TableType=Temporary must always report IsTemporary=true without the temporary variable modifier');
    end;

    [Test]
    procedure TempOnly_AutoIncrement_NotAssigned_OnInsert()
    var
        T: Record "ALT Temp Only";
    begin
        Initialize();
        // AutoIncrement is a database-level sequence; TableType=Temporary has no DB backing.
        T.Insert();
        Assert.AreEqual(0, T."Entry No.", 'AutoIncrement must NOT auto-assign on TableType=Temporary table');
    end;

    [Test]
    procedure TempOnly_TwoVariables_IsolatedBuffers()
    var
        T1: Record "ALT Temp Only";
        T2: Record "ALT Temp Only";
    begin
        Initialize();
        T1."Entry No." := 1;
        T1.Insert();
        Assert.AreEqual(1, T1.Count(), 'T1 must have 1 record');
        Assert.AreEqual(0, T2.Count(), 'T2 must be empty — isolated buffer from T1');
    end;

    // ── AutoIncrement on Record "X" temporary variable ────────────────────────

    [Test]
    procedure TempVar_AutoIncrement_NotAssigned_OnInsert()
    var
        TL: Record "ALT Trigger Log" temporary;
    begin
        Initialize();
        // ALT Trigger Log has AutoIncrement=true on Entry No.
        // When used as a temporary variable, the DB sequence is never called.
        TL.Insert();
        Assert.AreEqual(0, TL."Entry No.", 'AutoIncrement must NOT auto-assign when record is used as a temporary variable');
    end;

    [Test]
    procedure TempVar_AutoIncrement_SecondInsert_RequiresManualPk()
    var
        TL: Record "ALT Trigger Log" temporary;
    begin
        Initialize();
        // Inserting two records without setting Entry No. both get 0 → duplicate key error.
        // Callers must manage the PK themselves on temp tables with AutoIncrement fields.
        TL.Insert();         // Entry No. = 0
        TL."Entry No." := 1;
        TL.Insert();         // Entry No. = 1 — explicit assignment required
        Assert.AreEqual(2, TL.Count(), 'Two inserts with distinct manual keys must both succeed');
        TL.FindFirst();
        Assert.AreEqual(0, TL."Entry No.", 'First record must have Entry No. = 0 (first manual insert)');
    end;

    // ── Copy isolation ─────────────────────────────────────────────────────────

    [Test]
    procedure TempVar_Copy_ShareFalse_IndependentBuffers()
    var
        Src: Record "ALT Universal" temporary;
        Dst: Record "ALT Universal" temporary;
    begin
        Initialize();
        Src."Entry No." := 1;
        Src.Insert();
        // Copy(Src, false) on temp records: Dst gets an independent buffer (empty — does not clone Src's data).
        Dst.Copy(Src, false);
        // Insert a second record into Src after the copy was made.
        Src."Entry No." := 2;
        Src.Insert();
        // Dst is independent: later inserts into Src must not appear in Dst
        Assert.AreEqual(0, Dst.Count(), 'Copy(ShareTable=false) on temp record creates an independent empty buffer — Src data is not cloned');
        Assert.AreEqual(2, Src.Count(), 'Src must reflect its own second insert');
    end;

    [Test]
    procedure TempVar_Copy_ShareTrue_SharedBuffer()
    var
        Src: Record "ALT Universal" temporary;
        Dst: Record "ALT Universal" temporary;
    begin
        Initialize();
        Src."Entry No." := 1;
        Src.Insert();
        Dst.Copy(Src, true);
        Src."Entry No." := 2;
        Src.Insert();
        Assert.AreEqual(Src.Count(), Dst.Count(), 'Copy(ShareTable=true) must share the buffer — inserts via Src must be visible through Dst');
    end;

    // ── Pass-by-value vs pass-by-ref ──────────────────────────────────────────

    [Test]
    procedure TempVar_PassedByValue_CallerNotAffected()
    var
        Caller: Record "ALT Universal" temporary;
    begin
        Initialize();
        Caller."Entry No." := 1;
        Caller.Insert();
        InsertIntoTempByValue(Caller);
        Assert.AreEqual(1, Caller.Count(), 'Temp record passed by value: inserts in callee must NOT propagate back to caller');
    end;

    [Test]
    procedure TempVar_PassedByRef_CallerSeesInsert()
    var
        Caller: Record "ALT Universal" temporary;
    begin
        Initialize();
        Caller."Entry No." := 1;
        Caller.Insert();
        InsertIntoTempByRef(Caller);
        Assert.AreEqual(2, Caller.Count(), 'Temp record passed by var: inserts in callee must be visible to caller');
    end;

    local procedure InsertIntoTempByValue(T: Record "ALT Universal" temporary)
    begin
        T."Entry No." := 99;
        T.Insert();
        // BC pass-by-value on temp records: callee receives an independent empty buffer (not a clone of caller's data).
        // So after inserting one record, callee sees Count()=1.
        Assert.AreEqual(1, T.Count(), 'Callee with pass-by-value temp record sees only its own inserted record (buffer is independent)');
    end;

    local procedure InsertIntoTempByRef(var T: Record "ALT Universal" temporary)
    begin
        T."Entry No." := 99;
        T.Insert();
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
