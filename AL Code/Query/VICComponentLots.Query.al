query 50177 VICComponentLots
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICComponentLots';
    EntitySetName = 'VICComponentLots';
    Caption = 'Vicinity Component Lots';

// V4-2518 
    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Lot No." = filter(<> ''), "Remaining Quantity" = filter(<> 0);
            column(ItemNo; "Item No.") { }
            column(LocationCode; "Location Code") { }
            column(LotNo; "Lot No.") { }
            column(PostingDate; "Posting Date") { }
            column(Expiration_Date;"Expiration Date") { }
            column(RemainingQuantity; "Remaining Quantity") { }
            dataitem(ReservationEntry; "Reservation Entry")
            {
                DataItemLink = "Source Ref. No." = ItemLedgerEntry."Entry No.", "Lot No." = ItemLedgerEntry."Lot No.";
                SqlJoinType = LeftOuterJoin;
                column(ReservationEntryQuantityBase; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
