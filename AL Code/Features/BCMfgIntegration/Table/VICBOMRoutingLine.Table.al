table 50442 VIC_BOMRoutingLine
{
    Caption = 'VIC BOM Routing Line';
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
        field(3; OperationNo; Text[10])
        {
            Caption = 'Operation No.';
        }
        field(4; WorkCenterNo; Text[20])
        {
            Caption = 'Work Center No.';
        }
        field(5; vicProductionBOMId; Guid)
        {
            Caption = 'VIC Production BOM Id';
            TableRelation = VIC_BOM.SystemId;
        }
        field(7; LotSize; Decimal)
        {
            Caption = 'Lot Size';
        }
        field(8; SetupTime; Decimal)
        {
            Caption = 'Setup Time';
        }
        field(9; RunTime; Decimal)
        {
            Caption = 'Run Time';
        }
        field(10; PostProcessTime; Decimal)
        {
            Caption = 'Post Process Time';
        }
        field(11; LastModifiedDateTime; DateTime)
        {
            Caption = 'Last Modified Date Time';
        }
        field(12; PreviousOperationNo; Text[10])
        {
            Caption = 'Previous Operation No.';
        }
        field(13; NextOperationNo; Text[10])
        {
            Caption = 'Next Operation No.';
        }
    }
    keys
    {
        key(Key1; RoutingNo, Version, OperationNo)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        H: Record "Routing Header";
        L: Record "Routing Line";
    begin
        if not H.Get(Rec.RoutingNo) then begin
            H.Init();
            H."No." := Rec.RoutingNo;
            H.Insert(true);
        end;
        L.Init();
        L."Routing No." := H."No.";
        L."Operation No." := Rec.OperationNo;
        L."Previous Operation No." := Rec.PreviousOperationNo;
        L."Next Operation No." := Rec.NextOperationNo;
        L.Type := L.Type::"Work Center";
        L.Validate("No.", Rec.WorkCenterNo);
        L.Validate("Work Center No.", Rec.WorkCenterNo);
        L.Validate("Lot Size", Rec.LotSize);
        L.Validate("Setup Time", Rec.SetupTime);
        L.Validate("Run Time", Rec.RunTime);
        L.Validate("Move Time", Rec.PostProcessTime);
        L.Insert(true);
    end;
}
