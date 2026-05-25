// Fixtures used: ALT Blob (60008)

codeunit 60110 "Test Blob"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        Cleanup: Codeunit ALTFixtureCleanup;

    // ── Blob Tests ───────────────────────────────────────────────────────────────

    [Test]
    procedure Blob_HasValue_Empty_ReturnsFalse()
    var
        BlobRec: Record "ALT Blob";
    begin
        Initialize();
        BlobRec.Code := 'B1';
        BlobRec.Insert();
        BlobRec.Get('B1');
        Assert.IsFalse(BlobRec.Data.HasValue(), 'HasValue() must return false for empty blob');
    end;

    [Test]
    procedure Blob_HasValue_AfterWrite_ReturnsTrue()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
    begin
        Initialize();
        BlobRec.Code := 'B2';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('content');
        BlobRec.Insert();
        BlobRec.Get('B2');
        Assert.IsTrue(BlobRec.Data.HasValue(), 'HasValue() must return true after writing to blob');
    end;

    [Test]
    procedure Blob_Export_Import_PreservesContent()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadText: Text;
    begin
        Initialize();
        BlobRec.Code := 'B3';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('ExportContent');
        BlobRec.Insert();
        BlobRec.Get('B3');
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        // WriteText writes text with CR/LF, ReadText reads until CR/LF
        // After Insert/Get from DB, fresh InStream reads the stored data
        Assert.AreEqual('ExportContent', ReadText, 'Blob export/import must preserve exact content');
    end;

    [Test]
    procedure Blob_Length_AfterWrite_GreaterThanZero()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
    begin
        Initialize();
        BlobRec.Code := 'B4';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('LengthTest');
        BlobRec.Insert();
        BlobRec.Get('B4');
        Assert.IsTrue(BlobRec.Data.Length() > 0, 'Blob Length() must be greater than zero after writing');
    end;

    [Test]
    procedure Blob_CreateOutStream_ThenInStream_Works()
    var
        BlobRec: Record "ALT Blob";
        OutStr: OutStream;
        InStr: InStream;
        ReadText: Text;
    begin
        Initialize();
        BlobRec.Code := 'B5';
        BlobRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('StreamTest');
        BlobRec.Insert();
        BlobRec.Modify();
        BlobRec.Data.CreateInStream(InStr);
        InStr.ReadText(ReadText);
        Assert.AreEqual('StreamTest', ReadText, 'Creating in/out streams sequentially must work correctly');
    end;

    local procedure Initialize()
    begin
        Cleanup.Initialize();
    end;
}
