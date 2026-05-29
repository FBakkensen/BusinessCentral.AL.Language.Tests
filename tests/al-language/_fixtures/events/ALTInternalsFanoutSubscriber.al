codeunit 60017 "ALT Internal Fanout Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Internal Codeunit", 'OnValueComputed', '', false, false)]
    local procedure OnValueComputedFanoutA(Value: Integer; Result: Integer)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnValueComputedA';
        TrigLog.SourceEntryNo := Value;
        TrigLog.NewValue := Format(Result);
        TrigLog.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Internal Codeunit", 'OnValueComputed', '', false, false)]
    local procedure OnValueComputedFanoutB(Value: Integer; Result: Integer)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnValueComputedB';
        TrigLog.SourceEntryNo := Value;
        TrigLog.NewValue := Format(Result);
        TrigLog.Insert();
    end;
}
