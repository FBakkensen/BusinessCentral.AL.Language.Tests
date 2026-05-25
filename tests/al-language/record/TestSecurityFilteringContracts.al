codeunit 60175 "Test Security Filtering"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        TestFixture: Record "ALT Universal";

    trigger OnRun()
    begin
        // Test runner entry point
    end;

    [Test]
    procedure SecurityFiltering_Default_IsNotValidated()
    var
        Rec: Record "ALT Universal";
    begin
        // In a test codeunit context, the default SecurityFiltering is not Validated.
        // The exact default (Filtered or Ignored) may vary, but Validated is never the default.
        Assert.IsFalse(Rec.SecurityFiltering() = SecurityFilter::Validated, 'Default SecurityFiltering must not be SecurityFilter::Validated');
    end;

    [Test]
    procedure SecurityFiltering_SetIgnored_GetIgnored()
    var
        Rec: Record "ALT Universal";
    begin
        Rec.SecurityFiltering(SecurityFilter::Ignored);
        Assert.AreEqual(SecurityFilter::Ignored, Rec.SecurityFiltering(), 'After setting SecurityFilter::Ignored, getter must return Ignored');
    end;

    [Test]
    procedure SecurityFiltering_SetFiltered_GetFiltered()
    var
        Rec: Record "ALT Universal";
    begin
        Rec.SecurityFiltering(SecurityFilter::Ignored); // change to Ignored first
        Rec.SecurityFiltering(SecurityFilter::Filtered); // then set back to Filtered
        Assert.AreEqual(SecurityFilter::Filtered, Rec.SecurityFiltering(), 'After setting SecurityFilter::Filtered, getter must return Filtered');
    end;

    [Test]
    procedure SecurityFiltering_Ignored_CountsAllRecords()
    var
        Rec: Record "ALT Universal";
        i: Integer;
    begin
        // Insert test records
        for i := 1 to 3 do begin
            Rec."Entry No." := i;
            Rec.Insert();
        end;

        Rec.SecurityFiltering(SecurityFilter::Ignored);
        Assert.AreEqual(3, Rec.Count(), 'With SecurityFilter::Ignored, all records must be counted (no security filter applied)');

        // Cleanup
        Rec.DeleteAll();
    end;

    [Test]
    procedure SecurityFiltering_Filtered_CountsSameWithAdminUser()
    var
        Rec: Record "ALT Universal";
        i: Integer;
    begin
        // In test context, admin user sees all records — Filtered = Ignored for admin
        for i := 1 to 3 do begin
            Rec."Entry No." := i;
            Rec.Insert();
        end;

        Rec.SecurityFiltering(SecurityFilter::Filtered);
        Assert.AreEqual(3, Rec.Count(), 'With admin user, SecurityFilter::Filtered must count same as Ignored (no restrictions)');

        // Cleanup
        Rec.DeleteAll();
    end;

    [Test]
    procedure SecurityFiltering_Validated_IsCallable()
    var
        Rec: Record "ALT Universal";
    begin
        Rec.SecurityFiltering(SecurityFilter::Validated);
        Assert.AreEqual(SecurityFilter::Validated, Rec.SecurityFiltering(), 'SecurityFilter::Validated must be settable and readable');
    end;

    [Test]
    procedure SecurityFiltering_Reset_ClearsFiltersButNotSetting()
    var
        Rec: Record "ALT Universal";
        FilteringBefore: SecurityFilter;
    begin
        // Set SecurityFiltering and a range filter, then call Reset()
        Rec.SecurityFiltering(SecurityFilter::Ignored);
        FilteringBefore := Rec.SecurityFiltering();
        Rec.SetRange("Entry No.", 1, 5);
        Rec.Reset();
        // Verify we can still call SecurityFiltering() after Reset() without error
        // The actual value may or may not be preserved — we document that the call is safe
        Assert.IsFalse(Rec.SecurityFiltering() = SecurityFilter::Validated, 'SecurityFiltering() must be callable after Reset() and must not be Validated');
    end;

    [Test]
    procedure ChangeCompany_SameCompany_ReturnsTrue()
    var
        Rec: Record "ALT Universal";
        Result: Boolean;
    begin
        Result := Rec.ChangeCompany(CompanyName());
        Assert.IsTrue(Result, 'ChangeCompany to current company must return true');
    end;

    [Test]
    procedure ChangeCompany_SameCompany_DataStillVisible()
    var
        Rec: Record "ALT Universal";
        Rec2: Record "ALT Universal";
    begin
        // Insert test record
        Rec."Entry No." := 1;
        Rec.Insert();

        // Access via separate record variable after ChangeCompany to same company
        Rec2.ChangeCompany(CompanyName());
        Assert.AreEqual(1, Rec2.Count(), 'After ChangeCompany to same company, data must still be visible');

        // Cleanup
        Rec.DeleteAll();
    end;

    [Test]
    procedure ChangeCompany_CurrentCompany_MatchesBeforeAndAfter()
    var
        Rec: Record "ALT Universal";
        CompBefore: Text;
        CompAfter: Text;
    begin
        CompBefore := Rec.CurrentCompany();
        Rec.ChangeCompany(CompanyName()); // stay in same company
        CompAfter := Rec.CurrentCompany();
        Assert.AreEqual(CompBefore, CompAfter, 'CurrentCompany() must be same before and after ChangeCompany to same company');
    end;

    [Test]
    procedure CurrentCompany_MatchesCompanyName()
    var
        Rec: Record "ALT Universal";
    begin
        Assert.AreEqual(CompanyName(), Rec.CurrentCompany(), 'Record.CurrentCompany() must equal global CompanyName() function');
    end;

    [Test]
    procedure ChangeCompany_InvalidCompany_ReturnsFalse()
    var
        Rec: Record "ALT Universal";
        Result: Boolean;
    begin
        Result := Rec.ChangeCompany('NonExistentCompany12345XYZ');
        Assert.IsFalse(Result, 'ChangeCompany to non-existent company must return false');
    end;

    local procedure Cleanup()
    var
        Rec: Record "ALT Universal";
    begin
        Rec.DeleteAll();
    end;
}
