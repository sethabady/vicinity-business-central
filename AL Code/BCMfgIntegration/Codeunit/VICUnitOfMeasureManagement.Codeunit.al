codeunit 50480 VICUnitOfMeasureManagement
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Unit of Measure Management", 'OnBeforeGetQtyPerUnitOfMeasure', '', false, false)]
    procedure OnBeforeGetQtyPerUnitOfMeasureSubscriber(Item: Record Item; UnitOfMeasureCode: Code[10]; var QtyPerUnitOfMeasure: Decimal; var IsHandled: Boolean)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        IsHandled := true;
        QtyPerUnitOfMeasure := 0;
        Item.TestField("No.");
        if UnitOfMeasureCode in [Item."Base Unit of Measure", ''] then
            QtyPerUnitOfMeasure := 1;
        if (Item."No." <> ItemUnitOfMeasure."Item No.") or
           (UnitOfMeasureCode <> ItemUnitOfMeasure.Code)
        then begin
            if ItemUnitOfMeasure.Get(Item."No.", UnitOfMeasureCode) then begin
                ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
                QtyPerUnitOfMeasure := ItemUnitOfMeasure."Qty. per Unit of Measure";
            end;
        end;
    end;
}
