codeunit 60015 "ALT Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Event Publisher", 'OnBeforeAction', '', false, false)]
    local procedure OnBeforeActionHandler(EntryNo: Integer; var Handled: Boolean)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnBeforeAction';
        TrigLog.SourceEntryNo := EntryNo;
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Event Publisher", 'OnAfterAction', '', false, false)]
    local procedure OnAfterActionHandler(EntryNo: Integer; Result: Integer)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnAfterAction';
        TrigLog.SourceEntryNo := EntryNo;
        TrigLog.NewValue := Format(Result);
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Event Publisher", 'OnInternalStep', '', false, false)]
    local procedure OnInternalStepHandler(Step: Integer)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnInternalStep';
        TrigLog.SourceEntryNo := Step;
        TrigLog.Insert();
    end;
}
