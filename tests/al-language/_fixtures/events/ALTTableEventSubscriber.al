codeunit 60016 "ALT Table Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"ALT Triggered", 'OnAfterValidateEvent', 'Watched Field', false, false)]
    local procedure OnAfterValidateWatchedField(var Rec: Record "ALT Triggered")
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'TableOnAfterValidate';
        TrigLog.SourceEntryNo := Rec."Entry No.";
        TrigLog.NewValue := Rec."Watched Field";
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"ALT Triggered", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertTriggered(var Rec: Record "ALT Triggered")
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'TableOnAfterInsert';
        TrigLog.SourceEntryNo := Rec."Entry No.";
        TrigLog.NewEntryNo := Rec."Entry No.";
        TrigLog.NewIntegerValue := Rec.Value;
        TrigLog.NewValue := Rec."Watched Field";
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"ALT Triggered", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyTriggered(var Rec: Record "ALT Triggered")
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'TableOnAfterModify';
        TrigLog.SourceEntryNo := Rec."Entry No.";
        TrigLog.NewEntryNo := Rec."Entry No.";
        TrigLog.NewIntegerValue := Rec.Value;
        TrigLog.NewValue := Rec."Watched Field";
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"ALT Triggered", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteTriggered(var Rec: Record "ALT Triggered")
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'TableOnAfterDelete';
        TrigLog.SourceEntryNo := Rec."Entry No.";
        TrigLog.NewEntryNo := Rec."Entry No.";
        TrigLog.NewIntegerValue := Rec.Value;
        TrigLog.NewValue := Rec."Watched Field";
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"ALT Triggered", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameTriggered(var Rec: Record "ALT Triggered"; var xRec: Record "ALT Triggered")
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'TableOnAfterRename';
        TrigLog.SourceEntryNo := Rec."Entry No.";
        TrigLog.OldEntryNo := xRec."Entry No.";
        TrigLog.NewEntryNo := Rec."Entry No.";
        TrigLog.OldIntegerValue := xRec.Value;
        TrigLog.NewIntegerValue := Rec.Value;
        TrigLog.Insert();
    end;
}
