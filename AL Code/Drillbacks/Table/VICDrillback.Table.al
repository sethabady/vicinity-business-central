table 50422 VICDrillback
{
    Caption = 'VICDrillback';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Drillback ID"; Integer)
        {
            Caption = 'Drillback ID';
        }
        field(2; "Vicinity Screen"; Text[100])
        {
            Caption = 'Vicinity Screen';
        }
        field(3; "Drillback Hyperlink"; Text[200])
        {
            Caption = 'Drillback Hyperlink';
        }
    }
    keys
    {
        key(PK; "Drillback ID")
        {
            Clustered = true;
        }
    }
}
