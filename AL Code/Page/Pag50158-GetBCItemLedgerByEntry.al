page 50158 GetBCItemLedgerByEntry
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCItemLedgerByEntry';
    EntitySetName = 'GetBCItemLedgerByEntry';
    DelayedInsert = true;
    SourceTable = "Item Ledger Entry";
    Caption = 'GetBCItemLedgerByEntry';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("EntryNo"; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("PostingDate"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("DocumentNo"; "Document No.")
                {
                    ApplicationArea = All;
                }
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
                field(UoMCode; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("BatchNo"; "Vicinity Batch No.")
                {
                    ApplicationArea = All;
                }
                field("FacilityID"; "Vicinity Facility ID")
                {
                    ApplicationArea = All;
                }
                field("LineID"; "Vicinity Line ID No.")
                {
                    ApplicationArea = All;
                }
                field("EventID"; "Vicinity Event ID No.")
                {
                    ApplicationArea = All;
                }

                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("CostAmountActual"; "Cost Amount (Actual)")
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
