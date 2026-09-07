// BC Documentation:
//   https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/page/page-update-method
//   https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/page/page-onaftergetcurrrecord-trigger
// Scope: in-scope
// Fixtures used: Test Page Upd Agcr Row (60496), Test Page Upd Agcr Trace (60497),
//                Test Page Upd Agcr Facts (60498), Test Page Upd Agcr Save (60499),
//                Test Page Upd Agcr NoSave (60500), Test Page Upd Agcr Plain (60501),
//                Test Page Upd Agcr Action (60502), Assert (60021)
//
// TestPagePartAgcr_Tests (60815) pins WHEN a subpage part's own triggers fire while a page is
// opened and navigated. This file pins the other event that refreshes a page in place, and the
// one a card reaches for after editing a field: CurrPage.Update.
//
// The shape it is about is a FactBox that no link keeps current. The part here declares no
// SourceTable and no SubPageLink; its single control reads a page global, and the only writer
// of that global is a procedure the HOST calls from its own OnAfterGetCurrRecord. So the part
// can only ever show a newer value if the host's trigger runs again -- which makes the part's
// control a direct, value-level probe for "did OnAfterGetCurrRecord re-run", alongside the
// trace that says when.
//
// Four hosts, differing in one line each, because three separate explanations of a refresh are
// otherwise indistinguishable: the Update call, the SetValue round trip, and the write to the
// row. Save (60499) calls CurrPage.Update(true) from OnValidate, NoSave (60500) calls
// CurrPage.Update(false), Plain (60501) calls neither, and Action (60502) calls
// CurrPage.Update(true) from an action with no OnValidate involved at all.
//
// COUNTS ARE NOT ASSERTED, and that is deliberate: TestPagePartAgcr_Tests records the same AL
// producing a different repeat count for one trigger on the corpus CI legs than on a local
// onprem container. Every assertion here is presence, absence, or order relative to a named
// marker.
//
// Filed against AL Runner as issue 3377, where CurrPage.Update under a TestPage re-runs
// nothing and a part in this shape stays stale after SetValue.
codeunit 60503 "Test Page Upd Agcr Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    local procedure Initialize(No: Code[20])
    var
        Row: Record "Test Page Upd Agcr Row";
        Trace: Codeunit "Test Page Upd Agcr Trace";
    begin
        Row.DeleteAll();
        Row.Init();
        Row."No." := No;
        Row.Amount := 20;
        Row.Insert();
        Trace.Reset();
    end;

    local procedure AmountOf(No: Code[20]): Integer
    var
        Row: Record "Test Page Upd Agcr Row";
    begin
        Row.Get(No);
        exit(Row.Amount);
    end;

    // THE CLAIM, order half: CurrPage.Update(true) reached from a field's OnValidate re-runs the
    // host's OnAfterGetCurrRecord, and does so AFTER that OnValidate has returned -- not at the
    // call site. Both halves matter to a page whose trigger recomputes derived state: an
    // implementation that ran it inline would recompute from a record the OnValidate had not
    // finished with.
    [Test]
    procedure UpdateTrue_RefiresTheHostTrigger_AfterOnValidateReturns()
    var
        Host: TestPage "Test Page Upd Agcr Save";
        Trace: Codeunit "Test Page Upd Agcr Trace";
        Tail: Text;
    begin
        Initialize('SAVE');

        Host.OpenEdit();
        Host.Amount.SetValue(50);
        Tail := Trace.TailAfter('ValidateEnd');
        Host.Close();

        Assert.IsTrue(Trace.Contains('ValidateEnd'), 'the field''s OnValidate must have run to completion');
        Assert.IsTrue(StrPos(Tail, 'HostAGCR;') > 0,
            'CurrPage.Update(true) must re-run the host''s OnAfterGetCurrRecord after the OnValidate returns; trace tail was <' + Tail + '>');
        Assert.IsTrue(StrPos(Tail, 'PartRefresh;') > 0,
            'the re-run OnAfterGetCurrRecord must have reached the part it pushes values into; trace tail was <' + Tail + '>');
    end;

    // THE CLAIM, value half: the part is refreshed by nothing but that trigger, so after the
    // SetValue its control reads the new value. The open-time assertion is what makes the second
    // one mean something -- a part answering a constant 50, or an inert shell answering 0, fails
    // one of the two.
    [Test]
    procedure UpdateTrue_PartFedOnlyByTheHostTrigger_ShowsTheNewValue()
    var
        Host: TestPage "Test Page Upd Agcr Save";
        AtOpen: Integer;
        AfterSetValue: Integer;
    begin
        Initialize('SAVE');

        Host.OpenEdit();
        AtOpen := Host.Facts.Profit.AsInteger();
        Host.Amount.SetValue(50);
        AfterSetValue := Host.Facts.Profit.AsInteger();
        Host.Close();

        Assert.AreEqual(20, AtOpen, 'the part must show the seeded value when the host opens');
        Assert.AreEqual(50, AfterSetValue, 'the part must show the edited value once CurrPage.Update(true) has refreshed the host');
        Assert.AreEqual(50, AmountOf('SAVE'), 'CurrPage.Update(true) must also have saved the row');
    end;

    // The false arm separates the two things CurrPage.Update(true) does. Passing false still
    // re-runs the host's trigger, and does NOT write the row -- so the part, which recomputes
    // from the table, legitimately recomputes the value it already had. A test that only ever
    // looked at the part would read this as "no refresh happened"; the trace is what tells the
    // two apart.
    [Test]
    procedure UpdateFalse_RefiresTheHostTrigger_ButDoesNotSaveTheRow()
    var
        Host: TestPage "Test Page Upd Agcr NoSave";
        Trace: Codeunit "Test Page Upd Agcr Trace";
        Tail: Text;
        AfterSetValue: Integer;
    begin
        Initialize('NOSAVE');

        Host.OpenEdit();
        Host.Amount.SetValue(50);
        Tail := Trace.TailAfter('ValidateEnd');
        AfterSetValue := Host.Facts.Profit.AsInteger();

        Assert.IsTrue(StrPos(Tail, 'HostAGCR;') > 0,
            'CurrPage.Update(false) must re-run the host''s OnAfterGetCurrRecord too; trace tail was <' + Tail + '>');
        Assert.IsFalse(Trace.Contains('Modify'),
            'CurrPage.Update(false) must not write the row -- the table''s OnModify must not have fired');
        Assert.AreEqual(20, AmountOf('NOSAVE'), 'the row must still hold the seeded value while the page is open');
        Assert.AreEqual(20, AfterSetValue,
            'the part recomputes from the unwritten row, so it must still read the seeded value');

        Host.Close();
    end;

    // The control arm, and the negative direction of the whole file: with no CurrPage.Update
    // anywhere, the host's OnAfterGetCurrRecord does NOT run again after the SetValue. Every
    // other assertion here would survive an implementation that simply re-ran the trigger on
    // every field write; this one does not.
    [Test]
    procedure NoUpdate_DoesNotRefireTheHostTrigger()
    var
        Host: TestPage "Test Page Upd Agcr Plain";
        Trace: Codeunit "Test Page Upd Agcr Trace";
        Tail: Text;
        AfterSetValue: Integer;
    begin
        Initialize('PLAIN');

        Host.OpenEdit();
        Host.Amount.SetValue(50);
        Tail := Trace.TailAfter('ValidateEnd');
        AfterSetValue := Host.Facts.Profit.AsInteger();

        Assert.IsTrue(Trace.Contains('ValidateEnd'), 'the field''s OnValidate must have run to completion');
        Assert.AreEqual('', Tail,
            'without CurrPage.Update nothing may run after the OnValidate returns; trace tail was <' + Tail + '>');
        Assert.AreEqual(20, AfterSetValue, 'the part must still show the value its last refresh computed');
        Assert.AreEqual(20, AmountOf('PLAIN'), 'nothing saved the row, so it must still hold the seeded value');

        Host.Close();
    end;

    // CurrPage.Update is not an OnValidate affordance: called from an action, with the row
    // changed underneath the open page, it re-runs the host trigger just the same. This is what
    // makes the file's claim about Update rather than about the SetValue round trip.
    [Test]
    procedure UpdateTrue_FromAnAction_RefiresTheHostTrigger()
    var
        Row: Record "Test Page Upd Agcr Row";
        Host: TestPage "Test Page Upd Agcr Action";
        Trace: Codeunit "Test Page Upd Agcr Trace";
        Tail: Text;
        AtOpen: Integer;
        AfterAction: Integer;
    begin
        Initialize('ACTION');

        Host.OpenEdit();
        AtOpen := Host.Facts.Profit.AsInteger();

        Row.Get('ACTION');
        Row.Amount := 50;
        Row.Modify();

        Host.DoUpdate.Invoke();
        Tail := Trace.TailAfter('ActionEnd');
        AfterAction := Host.Facts.Profit.AsInteger();
        Host.Close();

        Assert.AreEqual(20, AtOpen, 'the part must show the seeded value when the host opens');
        Assert.IsTrue(StrPos(Tail, 'HostAGCR;') > 0,
            'CurrPage.Update(true) from an action must re-run the host''s OnAfterGetCurrRecord; trace tail was <' + Tail + '>');
        Assert.AreEqual(50, AfterAction, 'the part must show the value the re-run trigger recomputed from the changed row');
    end;
}
