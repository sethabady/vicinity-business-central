page 50151 GetBCBatchCompLots
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCBatchComponentLots';
    EntitySetName = 'GetBCBatchComponentLots';
    DelayedInsert = true;
    SourceTable = "Item Ledger Entry";
    Caption = 'GetBCBatchComponentLots';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ItemNo"; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("LocationCode"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("LotNo"; "Lot No.")
                {
                    ApplicationArea = All;
                }
                field("PostingDate"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("ExpirationDate"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("RemainingQuantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("ReservationEntryQuantityBase"; GetReservationEntryQuantity())
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    local procedure GetReservationEntryQuantity() ReservEntryQty: Decimal
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservEntryQty := 0;

        ReservationEntry.Reset();
        ReservationEntry.SetRange("Item No.", "Item No.");
        ReservationEntry.SetRange("Lot No.", "Lot No.");
        ReservationEntry.SetRange(Positive, false);
        if ReservationEntry.IsEmpty = false then begin
            ReservationEntry.CalcSums("Quantity (Base)");
            ReservEntryQty := ReservationEntry."Quantity (Base)";
        end;

        exit(ReservEntryQty);
    end;
}
