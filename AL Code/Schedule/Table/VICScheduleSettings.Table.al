table 50416 VICScheduleSettings
{
    DataClassification = ToBeClassified;
    // TableType = Temporary;
    fields
    {
        field(1; "PrimaryKey"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(3; Level1ScheduleGroupBy; Text[50])
        {
            Caption = 'Level 1';
            TableRelation = VICScheduleGroupBy.GroupBy;
        }
        field(5; Level2ScheduleGroupBy; Text[50])
        {
            Caption = 'Level 2';
            TableRelation = VICScheduleGroupBy.GroupBy;
        }
        field(10; "Group By"; Enum VICScheduleGroupBy)
        {
            Caption = 'NOTUSED';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key( PK; "PrimaryKey")
        {
            Clustered = true;
        }
    }
}
