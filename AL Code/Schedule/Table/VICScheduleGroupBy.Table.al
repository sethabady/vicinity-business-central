table 50415 VICScheduleGroupBy
{
    DataClassification = ToBeClassified;
    
//    TableType = Temporary;
    fields
    {
        field(10; GroupBy; Text[50])
        {
            Caption = 'Group By';
            DataClassification = ToBeClassified;
        }

        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(30; Type; Enum VICScheduleGroupBy)
        {
            DataClassification = ToBeClassified;
        }
        
        field(40; Level; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; GroupBy)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {}
    }
}

