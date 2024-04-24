table 50411 VICResource
{
    DataClassification = ToBeClassified;
    TableType = Temporary;
    fields
    {
        field(10; ResourceId; Text[15])
        {
            Caption = 'Resource ID';
            DataClassification = ToBeClassified;
        }

        field(15; ScheduleObjectId; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(20; ResourceType; Enum VICScheduleGroupBy)
        {
            Caption = 'Resource Type';
            DataClassification = ToBeClassified;
        }

        field(25; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; ResourceId, ResourceType)
        {
        }
    }
}