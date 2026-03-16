codeunit 50170 VICItemLotsAPIMgt
{
    procedure PopulateSummary(var Summary: Record "VICItemLots")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ReservationEntry: Record "Reservation Entry";
    begin
        Summary.DeleteAll();

        ItemLedgerEntry.SetCurrentKey("Item No.", "Lot No.", "Location Code");
        ItemLedgerEntry.SetFilter("Remaining Quantity", '<>0');
        ItemLedgerEntry.SetFilter("Lot No.", '<>%1', '');
        if ItemLedgerEntry.FindSet() then
            repeat
                if not Summary.Get(ItemLedgerEntry."Item No.", ItemLedgerEntry."Lot No.", ItemLedgerEntry."Location Code") then begin
                    Summary.Init();
                    Summary."Item No." := ItemLedgerEntry."Item No.";
                    Summary."Lot No." := ItemLedgerEntry."Lot No.";
                    Summary."Location Code" := ItemLedgerEntry."Location Code";
                    Summary.ReservationEntryQuantityBase := GetReservationEntrySum(ItemLedgerEntry);
                    Summary."Posting Date" := ItemLedgerEntry."Posting Date";
                    Summary."Expiration Date" := ItemLedgerEntry."Expiration Date";
                    Summary.Insert();
                end;
                Summary."Remaining Quantity" += ItemLedgerEntry."Remaining Quantity";
                Summary.Modify();
            until ItemLedgerEntry.Next() = 0;
    end;

    procedure GetReservationEntrySum(ItemLedgerEntry: Record "Item Ledger Entry"): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        TotalQuantity: Decimal;
    begin
        ReservationEntry.SetRange("Source Ref. No.", ItemLedgerEntry."Entry No.");
        ItemLedgerEntry.SetFilter("Lot No.", ItemLedgerEntry."Lot No.");
        if ReservationEntry.FindSet() then
            repeat
                TotalQuantity += ReservationEntry."Quantity (Base)";
            until ReservationEntry.Next() = 0;
        exit(TotalQuantity);
    end;
}