table 50430 VICFacilityTemp
{
    Caption = 'VICFacility';
    DataClassification = ToBeClassified;
    TableType = Temporary;

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
