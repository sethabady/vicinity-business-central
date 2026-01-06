table 50425 VICFacility
{
    Caption = 'VICFacility';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; FacilityId; Text[15])
        {
            Caption = 'FacilityId';
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
        }
    }
    keys
    {
        key(PK; FacilityId)
        {
            Clustered = true;
        }
    }
}
