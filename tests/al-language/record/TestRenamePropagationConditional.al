// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-rename-method
// Scope: in-scope (Cloud-compatible)
// Fixtures used: ALT Relation Parent (60028), ALT Relation Parent B (60030), ALT Relation Child (60029)
//
// CLAIM UNDER TEST: renaming a record's primary key propagates through CONDITIONAL
// (`if (Field = const(X)) TableA else TableB`) and WHERE-FILTERED
// (`TableA.Field where(...)`) TableRelations, honouring the condition/filter:
// an IF arm updates only child rows whose condition matches, and a where() filter
// propagates only when the renamed parent row satisfies it. The ELSE arm is the
// exception: it carries no condition of its own (BC does not apply the complement of
// the if-conditions), so an else-table rename updates every row whose ref value
// matches — including rows whose condition selects the if arm.
//
// Companion to "Test Rename Propagation" (60236), which covers the unconditional shapes.

codeunit 60239 "Test Rename Propagation Cond"
{
    Subtype = Test;
    TestPermissions = Disabled;
    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    [Test]
    procedure Record_Rename_ConditionalRelation_MatchingArm_Propagates()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        Parent."Code" := 'OLDCODE';
        Parent.Insert(false);

        Child."Entry No." := 1;
        Child.Kind := Child.Kind::A;
        Child."Conditional Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('NEWCODE', Child."Conditional Ref",
            'A row whose condition selects the renamed table''s arm must follow the parent rename');
    end;

    [Test]
    procedure Record_Rename_ConditionalRelation_NonMatchingArm_Untouched()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        Parent."Code" := 'OLDCODE';
        Parent.Insert(false);

        // Kind = B selects the ELSE arm (Parent B), so this row does not relate to
        // "ALT Relation Parent" even though the ref value coincides with its key.
        Child."Entry No." := 1;
        Child.Kind := Child.Kind::B;
        Child."Conditional Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('OLDCODE', Child."Conditional Ref",
            'A row whose condition selects the OTHER arm must not be touched by this parent''s rename, even when the values coincide');
    end;

    [Test]
    procedure Record_Rename_ConditionalRelation_ElseArm_Propagates()
    var
        ParentB: Record "ALT Relation Parent B";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        ParentB."Code" := 'BOLD';
        ParentB.Insert(false);

        Child."Entry No." := 1;
        Child.Kind := Child.Kind::B;
        Child."Conditional Ref" := 'BOLD';
        Child.Insert(false);

        ParentB.Rename('BNEW');

        Child.Get(1);
        Assert.AreEqual('BNEW', Child."Conditional Ref",
            'A row whose condition selects the else arm must follow the else table''s rename');
    end;

    [Test]
    procedure Record_Rename_ConditionalRelation_ElseTableRename_UpdatesIfArmRowsToo()
    var
        ParentB: Record "ALT Relation Parent B";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        ParentB."Code" := 'BOLD';
        ParentB.Insert(false);

        // Kind = A selects the IF arm — yet BC still rewrites this row when the ELSE
        // table renames. The else arm carries NO condition: BC does not apply the
        // complement of the if-conditions, so an else-table rename updates every row
        // whose ref value matches, regardless of which arm the row's condition selects.
        // (Verified against a real BC 28.3 service tier; the asymmetry with
        // Record_Rename_ConditionalRelation_NonMatchingArm_Untouched is deliberate.)
        Child."Entry No." := 1;
        Child.Kind := Child.Kind::A;
        Child."Conditional Ref" := 'BOLD';
        Child.Insert(false);

        ParentB.Rename('BNEW');

        Child.Get(1);
        Assert.AreEqual('BNEW', Child."Conditional Ref",
            'The else arm of a conditional relation is unconditional: an else-table rename updates matching rows even when their condition selects the if arm');
    end;

    [Test]
    procedure Record_Rename_SingleArmConditional_Match_Propagates()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        Parent."Code" := 'OLDCODE';
        Parent.Insert(false);

        Child."Entry No." := 1;
        Child.Kind := Child.Kind::A;
        Child."Single Cond Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('NEWCODE', Child."Single Cond Ref",
            'An if-without-else relation must propagate for rows whose condition matches');
    end;

    [Test]
    procedure Record_Rename_SingleArmConditional_NoMatch_Untouched()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        Parent."Code" := 'OLDCODE';
        Parent.Insert(false);

        // Kind = B matches no arm at all: the field has NO relation for this row.
        Child."Entry No." := 1;
        Child.Kind := Child.Kind::B;
        Child."Single Cond Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('OLDCODE', Child."Single Cond Ref",
            'An if-without-else relation covers no arm for a non-matching row; the rename must leave it untouched');
    end;

    [Test]
    procedure Record_Rename_FilteredRelation_ParentInFilter_Propagates()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        Parent."Code" := 'OLDCODE';
        Parent.Blocked := false;
        Parent.Insert(false);

        Child."Entry No." := 1;
        Child."Filtered Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('NEWCODE', Child."Filtered Ref",
            'Renaming a parent row that satisfies the relation''s where() filter must propagate');
    end;

    [Test]
    procedure Record_Rename_FilteredRelation_ParentOutsideFilter_Untouched()
    var
        Parent: Record "ALT Relation Parent";
        Child: Record "ALT Relation Child";
    begin
        Initialize();
        // Blocked = true falls outside where(Blocked = const(false)): the renamed row is
        // not a valid target of the relation, so no child row relates to it through it.
        Parent."Code" := 'OLDCODE';
        Parent.Blocked := true;
        Parent.Insert(false);

        Child."Entry No." := 1;
        Child."Filtered Ref" := 'OLDCODE';
        Child.Insert(false);

        Parent.Rename('NEWCODE');

        Child.Get(1);
        Assert.AreEqual('OLDCODE', Child."Filtered Ref",
            'Renaming a parent row outside the relation''s where() filter must not touch the child ref');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
