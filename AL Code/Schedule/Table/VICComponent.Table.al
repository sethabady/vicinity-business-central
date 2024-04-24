table 50414 VICComponent
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(10; ComponentId; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Description; Text[60])
        {
            DataClassification = ToBeClassified;
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
