interface IALTCompute
{
    procedure Compute(X: Integer): Integer;
}

codeunit 60011 ALTDouble implements IALTCompute
{
    procedure Compute(X: Integer): Integer
    begin
        exit(2 * X);
    end;
}

codeunit 60012 ALTSquare implements IALTCompute
{
    procedure Compute(X: Integer): Integer
    begin
        exit(X * X);
    end;
}
