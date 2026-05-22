codeunit 60187 "Test Case Contracts"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    trigger OnRun()
    begin
        Cleanup.Initialize();
    end;

    [Test]
    procedure Case_Integer_MatchesExactValue()
    var
        I: Integer;
    begin
        I := 2;
        case I of
            1:
                Assert.Fail('must not reach 1');
            2:
                Assert.IsTrue(true, 'case 2 must match when I=2');
            3:
                Assert.Fail('must not reach 3');
        end;
    end;

    [Test]
    procedure Case_Integer_Else_WhenNoMatch()
    var
        I: Integer;
        Result: Text;
    begin
        I := 99;
        Result := '';
        case I of
            1:
                Result := 'one';
            2:
                Result := 'two';
            else
                Result := 'other';
        end;
        Assert.AreEqual('other', Result, 'else branch must execute when no case matches');
    end;

    [Test]
    procedure Case_Integer_NoElse_SkipsIfNoMatch()
    var
        I: Integer;
        Result: Text;
    begin
        I := 99;
        Result := 'unchanged';
        case I of
            1:
                Result := 'one';
            2:
                Result := 'two';
        end;
        Assert.AreEqual('unchanged', Result, 'case with no else and no match must leave Result unchanged');
    end;

    [Test]
    procedure Case_Text_MatchesExactString()
    var
        S: Text;
        Result: Integer;
    begin
        S := 'hello';
        Result := 0;
        case S of
            'hello':
                Result := 1;
            'world':
                Result := 2;
            else
                Result := 0;
        end;
        Assert.AreEqual(1, Result, 'case text must match exact string "hello"');
    end;

    [Test]
    procedure Case_Text_IsCaseSensitive()
    var
        S: Text;
        Result: Integer;
    begin
        S := 'HELLO';
        Result := 0;
        case S of
            'hello':
                Result := 1;
            'HELLO':
                Result := 2;
            else
                Result := 0;
        end;
        Assert.AreEqual(2, Result, 'case text must be case-sensitive (HELLO matches HELLO not hello)');
    end;

    [Test]
    procedure Case_Enum_MatchesValue()
    var
        Status: Enum "ALT Status";
        Result: Text;
    begin
        Status := "ALT Status"::Active;
        Result := '';
        case Status of
            "ALT Status"::Draft:
                Result := 'draft';
            "ALT Status"::Active:
                Result := 'active';
            "ALT Status"::Closed:
                Result := 'closed';
            else
                Result := 'other';
        end;
        Assert.AreEqual('active', Result, 'case enum must match Active value');
    end;

    [Test]
    procedure Case_MultipleValuesInOneBranch()
    var
        I: Integer;
        Result: Text;
    begin
        I := 3;
        Result := '';
        case I of
            1, 2:
                Result := 'low';
            3, 4:
                Result := 'mid';
            5, 6:
                Result := 'high';
            else
                Result := 'other';
        end;
        Assert.AreEqual('mid', Result, 'case with comma-separated values: 3 must match 3,4 branch');
    end;

    [Test]
    procedure Case_MultipleValues_FirstOfGroup()
    var
        I: Integer;
        Result: Text;
    begin
        I := 1;
        Result := '';
        case I of
            1, 2:
                Result := 'one-or-two';
            3, 4:
                Result := 'three-or-four';
        end;
        Assert.AreEqual('one-or-two', Result, 'Both values in a branch must match: 1 matches 1,2');
    end;

    [Test]
    procedure Case_Boolean_TrueAndFalse()
    var
        B: Boolean;
        Result: Text;
    begin
        B := true;
        Result := '';
        case B of
            true:
                Result := 'yes';
            false:
                Result := 'no';
        end;
        Assert.AreEqual('yes', Result, 'case boolean true must match true branch');
    end;

    [Test]
    procedure Case_UnmatchedValue_ExecutesElse()
    var
        I: Integer;
        Result: Integer;
    begin
        I := 5;
        Result := 0;
        case I of
            1:
                Result := 1;
            2:
                Result := 2;
            else
                Result := 99;
        end;
        Assert.AreEqual(99, Result, 'else must execute for unmatched value 5');
    end;

    [Test]
    procedure Case_Code_UppercaseNormalized()
    var
        C: Code[20];
        Result: Text;
    begin
        C := 'hello';
        Result := '';
        case C of
            'HELLO':
                Result := 'matched';
            else
                Result := 'not matched';
        end;
        Assert.AreEqual('matched', Result, 'case on Code must match uppercase (Code normalizes on assign)');
    end;

    [Test]
    procedure Case_NestingWorks()
    var
        I: Integer;
        Result: Text;
    begin
        I := 2;
        Result := '';
        case I of
            1:
                Result := 'one';
            2:
                begin
                    case I * 2 of
                        4:
                            Result := 'two';
                        else
                            Result := 'unexpected';
                    end;
                end;
            else
                Result := 'other';
        end;
        Assert.AreEqual('two', Result, 'Nested case statement must work correctly');
    end;

    [Test]
    procedure Case_WithProcedureCall_InElse()
    var
        I: Integer;
        Result: Text;
    begin
        I := 7;
        Result := '';
        case I of
            1:
                Result := 'one';
            else
                Result := GetDefault(I);
        end;
        Assert.AreEqual('default-7', Result, 'else branch can call procedure');
    end;

    [Test]
    procedure Case_InLoop_SelectsCorrectly()
    var
        i: Integer;
        Sum: Integer;
    begin
        Sum := 0;
        for i := 1 to 3 do
            case i of
                1:
                    Sum += 10;
                2:
                    Sum += 20;
                3:
                    Sum += 30;
            end;
        Assert.AreEqual(60, Sum, 'case inside for loop must select correct branch each iteration (10+20+30=60)');
    end;

    local procedure GetDefault(I: Integer): Text
    begin
        exit('default-' + Format(I));
    end;
}
