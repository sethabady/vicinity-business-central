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
    // ApplicationArea = All;
    // UsageCategory = Lists;
    ODataKeyFields = "Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("EntryNo"; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("PostingDate"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("DocumentNo"; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("ItemNo"; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("LocationCode"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("LotNo"; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field(UoMCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("BatchNo"; Rec."Vicinity Batch No.")
                {
                    ApplicationArea = All;
                }
                field("FacilityID"; Rec."Vicinity Facility ID")
                {
                    ApplicationArea = All;
                }
                field("LineID"; Rec."Vicinity Line ID No.")
                {
                    ApplicationArea = All;
                }
                field("EventID"; Rec."Vicinity Event ID No.")
                {
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("CostAmountActual"; Rec."Cost Amount (Actual)")
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
        ReservationEntry.SetRange("Item No.", Rec."Item No.");
        ReservationEntry.SetRange("Lot No.", Rec."Lot No.");
        ReservationEntry.SetRange(Positive, false);
        if ReservationEntry.IsEmpty = false then begin
            ReservationEntry.CalcSums("Quantity (Base)");
            ReservEntryQty := ReservationEntry."Quantity (Base)";
        end;

        exit(ReservEntryQty);
    end;
}
