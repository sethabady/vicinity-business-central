page 50170 "VICItemLotsAPI"
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'itemlots';
    APIVersion = 'v1.0';
    EntityName = 'itemLotLocationSummary';
    EntitySetName = 'itemLotLocationSummaries';
    SourceTable = "VICItemLots";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(itemNo; rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(locationCode; rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(lotNo; rec."Lot No.")
                {
                    Caption = 'Lot No.';
                }
                field(postingDate; rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(expirationDate; rec."Expiration Date")
                {
                    Caption = 'Expiration Date';
                }
                field(remainingQuantity; rec."Remaining Quantity")
                {
                    Caption = 'Remaining Quantity';
                }
                field(reservationEntryQuantityBase; rec.ReservationEntryQuantityBase)
                {
                    Caption = 'Reservation Entry Quantity Base';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SummaryMgt: Codeunit VICItemLotsAPIMgt;
    begin
        SummaryMgt.PopulateSummary(Rec);
    end;
}