// Interface defined in the fixture (dependency) app.
// ALT Cross Compute implements it and returns X * 3.
// Purpose: prove that calling a method through an interface where both the
// interface definition and the implementing codeunit live in a dependency
// app works correctly — the cross-app interface dispatch scenario.
interface IALTCrossCompute
{
    procedure Evaluate(X: Integer): Integer;
}

codeunit 61004 "ALT Cross Compute" implements IALTCrossCompute
{
    procedure Evaluate(X: Integer): Integer
    begin
        exit(X * 3);
    end;
}
