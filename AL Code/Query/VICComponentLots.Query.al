query 50177 VICComponentLots
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICComponentLots';
    EntitySetName = 'VICComponentLots';
    Caption = 'Vicinity Component Lots';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Lot No." = filter(<> ''), "Remaining Quantity" = filter(<> 0);
            column("ItemNo"; "Item No.")
            {
            }
            column("LocationCode"; "Location Code")
            {
            }
            column("LotNo"; "Lot No.")
            {
            }
            column("PostingDate"; "Posting Date")
            {
            }
            column("ExpirationDate"; "Expiration Date")
            {
            }
            column("RemainingQuantity"; "Remaining Quantity")
            {
                // V4-2270
                Method = Sum;
            }
            dataitem(ReservationEntry; "Reservation Entry")
            {
                DataItemLink = "Item No." = Item_Ledger_Entry."Item No.", "Location Code" = Item_Ledger_Entry."Location Code", "Lot No." = Item_Ledger_Entry."Lot No.";
                SqlJoinType = LeftOuterJoin;

                column(ReservationEntryQuantityBase; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
