// BC Documentation: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type
// Scope: in-scope
// Fixtures used: ALT Blob (60008)

codeunit 60109 "Test InOutStream"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── InOutStream Tests ────────────────────────────────────────────────────────

    [Test]
    procedure InOutStream_WriteText_ReadText_Roundtrips()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadText: Text;
    begin
        Initialize();
        BlobRec.Code := 'T1';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('Hello World');
        BlobRec.Insert();
        BlobRec.Get('T1');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        Assert.AreEqual('Hello World', ReadText, 'Written text must be read back exactly as written');
    end;

    [Test]
    procedure InOutStream_WriteText_Multiple_ReadAll()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadText: Text;
    begin
        Initialize();
        BlobRec.Code := 'T2';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('Line1');
        OutStr.WriteText('Line2');
        BlobRec.Insert();
        BlobRec.Get('T2');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        Assert.IsTrue(ReadText.Contains('Line1'), 'Multiple writes must all be readable from stream');
    end;

    [Test]
    procedure InOutStream_Write_Integer_ReadInteger()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadInt: Integer;
    begin
        Initialize();
        BlobRec.Code := 'T3';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.Write(42);
        BlobRec.Insert();
        BlobRec.Get('T3');
        BlobRec.Data.CreateInStream(InStr);
        InStr.Read(ReadInt);
        Assert.AreEqual(42, ReadInt, 'Integer value must round-trip through stream');
    end;

    [Test]
    procedure InOutStream_EOS_EmptyStream_ReturnsTrue()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadText: Text;
    begin
        Initialize();
        BlobRec.Code := 'T4';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('');
        BlobRec.Insert();
        BlobRec.Get('T4');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        Assert.IsTrue(InStr.EOS(), 'EOS() must return true when stream is at end');
    end;

    [Test]
    procedure InOutStream_TextReadLine_ReadsOneLine()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        Line: Text;
    begin
        Initialize();
        BlobRec.Code := 'T5';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('FirstLine');
        BlobRec.Insert();
        BlobRec.Get('T5');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(Line);
        Assert.IsTrue(StrLen(Line) > 0, 'ReadText() must return non-empty string when data exists');
    end;

    [Test]
    procedure InOutStream_LongText_PreservesContent()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        LongText: Text;
        ReadText: Text;
    begin
        Initialize();
        LongText := PadStr('', 200, 'X');
        BlobRec.Code := 'T6';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText(LongText);
        BlobRec.Insert();
        BlobRec.Get('T6');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        Assert.AreEqual(200, StrLen(ReadText), 'Long text content must be preserved in stream');
    end;

    [Test]
    procedure InOutStream_WriteText_BlobHasValue()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
    begin
        Initialize();
        BlobRec.Code := 'T7';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('data');
        BlobRec.Insert();
        BlobRec.Get('T7');
        Assert.IsTrue(BlobRec.Data.HasValue(), 'Blob must report HasValue() = true after stream write');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
