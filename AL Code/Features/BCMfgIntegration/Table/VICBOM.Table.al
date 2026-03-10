table 50440 VIC_BOM
{
    Caption = 'VIC BOM';
    TableType = Temporary;
    DataClassification = ToBeClassified;

    fields
    {
        field(2; BOMNo; Text[20])
        {
            Caption = 'BOM No';
        }
        field(3; Version; Text[20])
        {
            Caption = 'Version';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; ProductionBOMHeaderSystemId; Guid)
        {
            Caption = 'Production BOM Header SystemId';
        }
        field(6; UnitOfMeasure; Text[10])
        {
            Caption = 'Unit of Measure';
        }
        field(7; Status; Enum "BOM Status")
        {
            Caption = 'Status';
        }
        field(8; RoutingNo; Text[20])
        {
            Caption = 'Routing No.';
        }
        field(9; RoutingVersion; Text[20])
        {
            Caption = 'Routing Version';
        }
        field(10; RoutingDescription; Text[100])
        {
            Caption = 'Routing Description';
        }
        field(11; RoutingStatus; Enum "Routing Status")
        {
            Caption = 'Routing Status';
        }
        field(12; LastModifiedDateTime; DateTime)
        {
            Caption = 'Last Modified Date Time';
        }
    }
    keys
    {
        key(Key1; BOMNo, Version)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        H: Record "Production BOM Header";
        L: Record "Production BOM Line";
        RH: Record "Routing Header";
        RL: Record "Routing Line";
    begin
        if not H.Get(BomNo) then begin
            H.Init();
            H."No." := BomNo;
            H.Status := H.Status::"Under Development";
            H.Insert(true);
        end
        else begin  
            if H.Status <> H.Status::"Under Development" then
                Error('Only production BOMs with status ''Under Development'' can be created or updated through the API.');
        end;
        if (Rec.RoutingNo <> '') then begin
            if (not RH.Get(Rec.RoutingNo)) then begin
                RH.Init();
                RH."No." := Rec.RoutingNo;
                RH.Status := RH.Status::"Under Development";
                RH.Insert(true);
            end
            else begin  
                if RH.Status <> RH.Status::"Under Development" then
                    Error('Only routings with status ''Under Development'' can be linked to the production BOM through the API.');
            end;
            RH."No." := RoutingNo;
            RH.Description := RoutingDescription;
            RH.Modify(true);
        end;
        H.Description := Description;
        H.Validate("Unit of Measure Code", UnitOfMeasure);
        H.Validate(Status, Status);
        H.Modify(true);
        Rec.ProductionBOMHeaderSystemId := H.SystemId;

        // Replace lines
        L.SetRange("Production BOM No.", BomNo);
        if L.FindSet(true) then
            L.DeleteAll(true);
        RL.SetRange("Routing No.", Rec.RoutingNo);
        if RL.FindSet(true) then
            RL.DeleteAll(true);
    end;
}