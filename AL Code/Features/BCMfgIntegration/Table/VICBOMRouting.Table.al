table 50443 VIC_BOMRouting
{
    Caption = 'VIC BOM Routing';
    TableType = Temporary;
    DataClassification = ToBeClassified;

    fields
    {
        field(1; RoutingNo; Text[20])
        {
            Caption = 'Routing No.';
            Editable = false;
        }
        field(2; Version; Text[20])
        {
            Caption = 'Version';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Status; Enum "Routing Status")
        {
            Caption = 'Status';
        }
        field(6; vicProductionBOMId; Guid)
        {
            Caption = 'VIC Production BOM Id';
            TableRelation = VIC_BOM.SystemId;
        }
    }
    keys
    {
        key(Key1; RoutingNo, Version)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        RH: Record "Routing Header";
        RL: Record "Routing Line";
    begin
        if not RH.Get(RoutingNo) then begin
            RH.Init();
            RH."No." := RoutingNo;
            RH.Status := RH.Status::"Under Development";
            RH.Insert(true);
        end
        else begin  
            if RH.Status <> RH.Status::"Under Development" then
                Error('Only routings with status ''Under Development'' can be created or updated through the API.');
        end;
        RH.Description := Description;
        RH.Validate(Status, Status);
        RH.Modify(true);

        // Replace lines
        RL.SetRange("Routing No.", Rec.RoutingNo);
        if RL.FindSet(true) then
            RL.DeleteAll(true);
    end;
}
