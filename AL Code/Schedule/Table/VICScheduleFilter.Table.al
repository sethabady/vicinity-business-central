table 50418 VICScheduleFilter
{
    Caption = 'Filter Schedule Buffer';
    ReplicateData = false;
    TableType = Temporary;

    fields
    {
        field(1; OrderNumber; Text[250])
        {
            Caption = 'Batch or Planned Order';
            DataClassification = SystemMetadata;
        }
        field(2; Formula; Text[250])
        {
            Caption = 'Formula';
            DataClassification = SystemMetadata;
        }
        field(3; Component; Text[250])
        {
            Caption = 'Component';
            DataClassification = SystemMetadata;
        }
        field(4; ID; Guid)
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if IsNullGuid(ID) then
            ID := CreateGuid;
    end;
}

