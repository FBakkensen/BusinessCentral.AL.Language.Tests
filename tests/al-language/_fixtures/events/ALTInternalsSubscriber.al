codeunit 60020 "ALT Internals Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ALT Internal Codeunit", 'OnValueComputed', '', false, false)]
    local procedure OnValueComputedHandler(Value: Integer; Result: Integer)
    var
        TrigLog: Record "ALT Trigger Log";
    begin
        TrigLog.Init();
        TrigLog.TriggerName := 'OnValueComputed';
        TrigLog.SourceEntryNo := Value;
        TrigLog.NewValue := Format(Result);
        TrigLog.Insert();
    end;
}
