query 50155 GetBCBatchCompLotsB
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCBatchComponentLotsB';
    EntitySetName = 'GetBCBatchComponentLotsB';
    Caption = 'GetBCBatchComponentLotsB';

    elements
    {

        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Lot No." = filter(<> '');
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
            }
            dataitem(ReservationEntry; "Reservation Entry")
            {
                DataItemLink = "Item No." = Item_Ledger_Entry."Item No.", "Lot No." = Item_Ledger_Entry."Lot No.";
                SqlJoinType = LeftOuterJoin;

                column(ReservationEntryQuantityBase; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
