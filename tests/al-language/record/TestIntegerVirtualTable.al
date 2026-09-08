// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-data-type
// Scope: in-scope
// Fixtures used: none (the built-in Integer virtual table, system object 2000000026)
//
// Pins the built-in Integer system virtual table: one row per value of Number.
// `dataitem(Name; Integer)` with a DataItemTableView filter is a standard idiom for a
// synthetic report/loop dataset, so a Record Integer that returns zero rows, or that
// answers every Find as true regardless of filter, silently changes program behavior
// without raising anything. The negative tests below carry as much weight as the
// positive ones: a provider that answers every Find with true, or that ignores the
// filter and returns a fixed row, would satisfy the positive cases on their own.
//
// The last three tests pin HOW FAR the table reaches, in both directions, and that an
// open-ended filter is answered rather than refused. Every other test here sits within a
// few rows of zero, so a provider that materialised a small window around zero would pass
// all of them; these say that Number 250000 and Number -250000 are ordinary rows, and that
// `SetFilter(Number, '>=1')` — the shape a report loop driver uses — yields rows rather
// than an error.
//
// Three later tests ask what a filter naming SEVERAL ranges selects — the union of all of
// them, not the outermost bounds they span — and how far the table reaches by KEY in both
// directions.

codeunit 60368 "Test Integer Virtual Table"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Record_Integer_ConstFilter_YieldsExactlyTheRequestedRow()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // [GIVEN] the shape `dataitem(OneRow; Integer) DataItemTableView = sorting(Number) where(Number = const(1))` uses
        IntRec.SetRange(Number, 1);

        // [WHEN] finding the first row for that filter
        Assert.IsTrue(IntRec.FindFirst(), 'Record Integer with Number = 1 was not found — the Integer virtual table has no rows.');

        // [THEN] exactly the requested row comes back
        Assert.AreEqual(1, IntRec.Number, 'Expected Number = 1');
        Assert.AreEqual(1, IntRec.Count(), 'Expected exactly 1 row for Number = const(1)');
    end;

    [Test]
    procedure Record_Integer_RangeFilter_YieldsEveryValueInOrder()
    var
        IntRec: Record Integer;
        Expected: Integer;
        Seen: Integer;
    begin
        Initialize();

        // [GIVEN] a range filter
        IntRec.SetRange(Number, 5, 9);

        // [THEN] the provider honours the range and returns ascending Number, rather than
        // repeating one row — a fixed-row provider fails the ordering check.
        Assert.AreEqual(5, IntRec.Count(), 'Expected 5 rows for Number in [5..9]');

        Expected := 5;
        if IntRec.FindSet() then
            repeat
                Assert.AreEqual(Expected, IntRec.Number, StrSubstNo('Expected Number %1 at position %2', Expected, Seen + 1));
                Expected += 1;
                Seen += 1;
            until IntRec.Next() = 0;

        Assert.AreEqual(5, Seen, 'Expected to iterate 5 rows');
    end;

    [Test]
    procedure Record_Integer_ZeroAndNegativeNumbers_AreRealRows()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // Real BC's Integer table spans the signed range, so 0 and negatives exist.
        // A provider seeded with only 1..N would pass the two tests above and fail here.
        IntRec.SetRange(Number, 0);
        Assert.IsTrue(IntRec.FindFirst(), 'Record Integer with Number = 0 was not found — 0 is a real row in BC.');
        Assert.AreEqual(0, IntRec.Number, 'Expected Number = 0');

        IntRec.Reset();
        IntRec.SetRange(Number, -3, -1);
        Assert.AreEqual(3, IntRec.Count(), 'Expected 3 rows for Number in [-3..-1]');
    end;

    [Test]
    procedure Record_Integer_EmptyRange_FindsNothing()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // Negative control: a provider that answers true unconditionally fails here.
        IntRec.SetRange(Number, 10, 4); // inverted — matches nothing
        Assert.IsFalse(IntRec.FindFirst(), 'Record Integer returned a row for the empty range [10..4].');
        Assert.IsTrue(IntRec.IsEmpty(), 'Expected IsEmpty() = true for the empty range [10..4].');
        Assert.AreEqual(0, IntRec.Count(), 'Expected 0 rows for the empty range [10..4]');
    end;

    [Test]
    procedure Record_Integer_RangeFarAboveAnySeededWindow_YieldsTheWholeRange()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // The rows here sit far above where a provider that merely seeds "enough for a report
        // loop" would stop. Number 250000 is an ordinary row on the service tier, so a Get for
        // it succeeds and a closed range ending there is counted in full.
        //
        // The count is asserted as well as the endpoint because those two fail differently: a
        // provider seeded to 100000 answers Count() with a plausible short number while
        // Get(250000) answers false outright, and only one of the two looks wrong on its own.
        Assert.IsTrue(IntRec.Get(250000), 'Record Integer has no row for Number = 250000.');
        Assert.AreEqual(250000, IntRec.Number, 'Expected Get(250000) to return Number 250000.');

        IntRec.Reset();
        IntRec.SetRange(Number, 249000, 250000);
        Assert.AreEqual(1001, IntRec.Count(), 'Expected 1001 rows for Number in [249000..250000].');
        Assert.IsFalse(IntRec.IsEmpty(), 'Number in [249000..250000] must not be empty.');
        Assert.IsTrue(IntRec.FindFirst(), 'Record Integer found no row for Number in [249000..250000].');
        Assert.AreEqual(249000, IntRec.Number, 'Expected the range to start at 249000.');
    end;

    [Test]
    procedure Record_Integer_RangeFarBelowZero_YieldsTheWholeRange()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // The same question at the other end. A provider that treats 0 as its floor, or that
        // seeds only a small negative margin, passes the -3..-1 test above and fails here.
        Assert.IsTrue(IntRec.Get(-250000), 'Record Integer has no row for Number = -250000.');
        Assert.AreEqual(-250000, IntRec.Number, 'Expected Get(-250000) to return Number -250000.');

        IntRec.Reset();
        IntRec.SetRange(Number, -250000, -249000);
        Assert.AreEqual(1001, IntRec.Count(), 'Expected 1001 rows for Number in [-250000..-249000].');
    end;

    [Test]
    procedure Record_Integer_HalfOpenFilter_IsAnsweredRatherThanRefused()
    var
        IntRec: Record Integer;
        Seen: Integer;
    begin
        Initialize();

        // `dataitem(N; Integer)` with no upper bound is a standard idiom — a loop driver whose
        // real limit is MaxIteration or an explicit exit, not the filter. So an open-ended
        // filter must be ANSWERED, not refused, and its first row must be the closed end.
        //
        // Only the first few rows are walked: this pins where the range starts and that it
        // continues, without asserting a total the service tier computes from a bound this test
        // deliberately does not name.
        IntRec.SetFilter(Number, '>=1');
        Assert.IsTrue(IntRec.FindSet(), 'An open-ended Integer filter returned no rows.');
        Assert.AreEqual(1, IntRec.Number, 'Expected the open-ended range to start at 1.');

        repeat
            Seen += 1;
        until (IntRec.Next() = 0) or (Seen >= 5);
        Assert.AreEqual(5, Seen, 'Expected an open-ended Integer filter to keep yielding rows.');

        // The mirror shape: open at the LOW end, closed at the high one. FindLast must land on
        // the closed bound.
        IntRec.Reset();
        IntRec.SetFilter(Number, '..7');
        Assert.IsTrue(IntRec.FindLast(), 'A low-open Integer filter returned no rows.');
        Assert.AreEqual(7, IntRec.Number, 'Expected the low-open range to end at 7.');
    end;

    [Test]
    procedure Record_Integer_MultiRangeFilter_YieldsEveryRangeNotJustTheFirst()
    var
        IntRec: Record Integer;
        I: Integer;
    begin
        Initialize();

        // A filter expression may name several ranges separated by `|`, and the rows it selects
        // are their UNION. Mixing a closed range with a half-open one is the shape a provider
        // that reads only the filter's outermost bounds gets wrong: the envelope of
        // `1..50|200000..` is 1..50, so such a provider answers 50 rows and drops the second
        // range entirely without reporting anything.
        //
        // The walk stays inside 51 rows and never names the bound the service tier substitutes
        // for the open end. `Next` is asserted step by step rather than driven from a loop
        // condition, because AL does not short-circuit `and`.
        IntRec.SetFilter(Number, '1..50|200000..');
        Assert.IsTrue(IntRec.FindSet(), 'A multi-range Integer filter returned no rows.');
        Assert.AreEqual(1, IntRec.Number, 'Expected the first range to start at 1.');

        for I := 1 to 49 do
            Assert.AreEqual(1, IntRec.Next(), 'Expected the first range to yield 50 consecutive rows.');
        Assert.AreEqual(50, IntRec.Number, 'Expected the 50th row of the first range to be Number 50.');

        // The row after the closed range's end is the second range's closed end, not nothing.
        Assert.AreEqual(1, IntRec.Next(), 'Expected a row after the first range ended — the second range was dropped.');
        Assert.AreEqual(200000, IntRec.Number, 'Expected the row after 50 to be the second range''s low bound 200000.');

        // The mirror: the half-open range comes FIRST and is open at the LOW end, so its closed
        // end (-200000) is not the filter's outermost bound in either direction either.
        IntRec.Reset();
        IntRec.SetFilter(Number, '..-200000|1..50');
        Assert.IsTrue(IntRec.FindLast(), 'A multi-range Integer filter with a low-open range returned no rows.');
        Assert.AreEqual(50, IntRec.Number, 'Expected the last row to be the closed range''s high bound 50.');

        for I := 1 to 49 do
            Assert.AreEqual(-1, IntRec.Next(-1), 'Expected the closed range to yield 50 consecutive rows walked backwards.');
        Assert.AreEqual(1, IntRec.Number, 'Expected the 50th row walked backwards to be Number 1.');

        Assert.AreEqual(-1, IntRec.Next(-1), 'Expected a row below 1 — the low-open range was dropped.');
        Assert.AreEqual(-200000, IntRec.Number, 'Expected the row below 1 to be the low-open range''s high bound -200000.');
    end;

    [Test]
    procedure Record_Integer_TwoClosedRanges_CountTheirUnion()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // The same union, with both ranges closed so the total is a number this test can name.
        // 50 rows from 1..50 and 10 from 200000..200009; a provider answering from the envelope
        // 1..200009 would report 200009, and one reading only the first range would report 50.
        IntRec.SetFilter(Number, '1..50|200000..200009');
        Assert.AreEqual(60, IntRec.Count(), 'Expected a two-range Integer filter to count the union of both ranges.');

        IntRec.Reset();
        IntRec.SetFilter(Number, '-200009..-200000|1..50');
        Assert.AreEqual(60, IntRec.Count(), 'Expected a two-range Integer filter spanning zero to count the union of both ranges.');
    end;

    [Test]
    procedure Record_Integer_KeyedGetPastOneBillion_AnswersFalse()
    var
        IntRec: Record Integer;
    begin
        Initialize();

        // How far the table reaches by KEY, in both directions. 1000000000 and -1000000000 are
        // rows; one step further is not. Pairing each edge with its neighbour is what makes this
        // a statement about where the boundary IS — a provider that answers FALSE for everything
        // large, or TRUE for every Get, fails one half or the other.
        Assert.IsTrue(IntRec.Get(1000000000), 'Expected Number 1000000000 to be a row of the Integer table.');
        Assert.IsTrue(IntRec.Get(-1000000000), 'Expected Number -1000000000 to be a row of the Integer table.');

        Assert.IsFalse(IntRec.Get(1000000001), 'Expected Number 1000000001 to be past the Integer table''s upper end.');
        Assert.IsFalse(IntRec.Get(-1000000001), 'Expected Number -1000000001 to be past the Integer table''s lower end.');
    end;

    local procedure Initialize()
    begin
        // Record Integer is a read-only system virtual table — nothing to DeleteAll.
    end;
}
