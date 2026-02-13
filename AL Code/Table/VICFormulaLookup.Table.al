table 50431 "VICFormulaLookup"
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; "Code"; Text[32]) { Caption = 'Formula ID'; }
        field(2; "Description"; Text[100]) { Caption = 'Description'; }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}