// Extends "Item Journal Batch" (table 233) with two test fields.
// Purpose: prove that a dependent app can read/write fields added by a
// dependency app's tableextension — the symbol-merge scenario that caused
// AL0132/AL0133 in the BC Runner.
tableextension 61002 "ALT Item Journal Batch Ext" extends "Item Journal Batch"
{
    fields
    {
        field(50000; "ALT Foo"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(50001; "ALT Bar"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
    }
}
