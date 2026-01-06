table 50414 VICComponent
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; ComponentId; Text[32])
        {
            Caption = 'Component ID';
        }
        field(2; Description; Text[60])
        {
            Caption = 'Name';
        }
        field(30; DefaultFacilityId; Text[15])
        {
            Caption = 'Default Facility ID';
        }
    }

    keys
    {
        key(Key1; ComponentId)
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
    }
}
