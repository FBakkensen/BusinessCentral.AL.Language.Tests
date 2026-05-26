codeunit 61000 "ALT Internal Codeunit"
{
    Access = Internal;

    procedure Compute(Value: Integer): Integer
    begin
        exit(Value * 2);
    end;

    [IntegrationEvent(false, false)]
    procedure OnValueComputed(Value: Integer; Result: Integer)
    begin
    end;

    procedure ComputeAndPublish(Value: Integer): Integer
    var
        Res: Integer;
    begin
        Res := Value * 2;
        OnValueComputed(Value, Res);
        exit(Res);
    end;
}
