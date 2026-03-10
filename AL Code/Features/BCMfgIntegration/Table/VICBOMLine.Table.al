table 50441 VIC_BOMLine
{
    Caption = 'VIC BOM Line';
    TableType = Temporary;
    DataClassification = ToBeClassified;

    fields
    {
        field(1; BOMNo; Text[20])
        {
            Caption = 'BOM No';
            Editable = false;
        }
        field(2; LineNo; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Version; Text[20])
        {
            Caption = 'Version';
        }
        field(4; vicProductionBOMId; Guid)
        {
            Caption = 'VIC Production BOM Id';
            TableRelation = VIC_BOM.SystemId;
        }
        field(5; BOMComponentNo; Text[20])
        {
            Caption = 'BOM Component No.';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(7; UnitOfMeasure; Text[10])
        {
            Caption = 'Unit of Measure';
        }
        field(8; ScrapPercentage; Decimal)
        {
            Caption = 'Scrap Percentage';
        }
        field(10; Type; Enum "Production BOM Line Type")
        {
            Caption = 'Type';
        }
        field(11; SizingUnitOfMeasure; Text[10])
        {
            Caption = 'Sizing Unit of Measure';
        }
    }
    keys
    {
        key(Key1; BOMNo, Version, LineNo)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        L: Record "Production BOM Line";
        QtyPerVicinitySizingUnitOfMeasure: Decimal;
        QuantityPer: Decimal;
        ItemRec: Record Item;
        VICUnitOfMeasureManagement: Codeunit VICUnitOfMeasureManagement;
        IsHandled: Boolean;
    begin
        L."Production BOM No." := BOMNo;
        L."Line No." := LineNo;
        L.Type := L.Type::Item;
        L.Validate("No.", BOMComponentNo);
        QuantityPer := Quantity;
        if (SizingUnitOfMeasure <> '') AND (SizingUnitOfMeasure <> UnitOfMeasure) then 
        begin
            if ItemRec.Get(Rec.BOMComponentNo) then begin
                VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, UnitOfMeasure, QtyPerVicinitySizingUnitOfMeasure, IsHandled);
                QuantityPer := Quantity / QtyPerVicinitySizingUnitOfMeasure;
                L.Validate("Unit of Measure Code", 'LB');
            end
        end
        else begin
            L.Validate("Unit of Measure Code", UnitOfMeasure);
        end;
        L.Validate("Quantity per", QuantityPer);
        L.Insert(true);
    end;
}