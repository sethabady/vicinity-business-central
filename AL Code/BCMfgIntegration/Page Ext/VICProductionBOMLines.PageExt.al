pageextension 50148 VICProductionBOMLines extends "Production BOM Lines"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
            begin
                QtyPerWeight := 0;
                QtyPerVolume := 0;
                // if ItemRec.Get(Rec."No.") then
                // begin
                //     VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'LB', QtyPerUnitOfMeasure, IsHandled);
                //     QtyPerWeight := Rec."Quantity per" * QtyPerUnitOfMeasure;
                //     VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'GAL', QtyPerUnitOfMeasure, IsHandled);
                //     QtyPerVolume := QtyPerWeight * QtyPerUnitOfMeasure;
                // end
                // else begin
                //     QtyPerVolume := 0;
                //     QtyPerWeight := 0;
                // end;
            end;
        }
        modify("Quantity per")
        {
            trigger OnAfterValidate()                
            var
            begin
                if ItemRec.Get(Rec."No.") then
                begin
                    VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'LB', QtyPerUnitOfMeasure, IsHandled);
                    QtyPerWeight := Rec."Quantity per" * QtyPerUnitOfMeasure;
                    VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'GAL', QtyPerUnitOfMeasure, IsHandled);
                    QtyPerVolume := QtyPerWeight * QtyPerUnitOfMeasure;
                end
                else begin
                    QtyPerVolume := 0;
                    QtyPerWeight := 0;
                end;
            end;
        }
        addafter("Unit of Measure Code")
        {
            field(QtyPerWeight; QtyPerWeight)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'Qty. per Weight';
                DecimalPlaces = 6;
            }
            field(QtyPerVolume; QtyPerVolume)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'Qty. per Volume';
                DecimalPlaces = 6;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        QtyPerWeight := 0;
        QtyPerVolume := 0;
    end;

    trigger OnAfterGetRecord()
    var
        IsHandled: Boolean;
    begin
        QtyPerWeight := 0;
        QtyPerVolume := 0;
        if (Rec."No." <> '') and (Rec.Type = Rec.Type::Item) then 
        begin
            if ItemRec.Get(Rec."No.") then
            begin
                VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'LB', QtyPerUnitOfMeasure, IsHandled);
                QtyPerWeight := Rec."Quantity per" * QtyPerUnitOfMeasure;
                VICUnitOfMeasureManagement.OnBeforeGetQtyPerUnitOfMeasureSubscriber(ItemRec, 'GAL', QtyPerUnitOfMeasure, IsHandled);
                QtyPerVolume := QtyPerWeight * QtyPerUnitOfMeasure;
            end;
        end
    end;

    var
        ItemRec: Record Item;
        VICUnitOfMeasureManagement: Codeunit VICUnitOfMeasureManagement;
        IsHandled: Boolean;

//        UnitOfMeasureManagement: Codeunit "Unit of Measure Management";
        QtyPerUnitOfMeasure: Decimal;
        QtyPerWeight: Decimal;
        QtyPerVolume: Decimal;
}