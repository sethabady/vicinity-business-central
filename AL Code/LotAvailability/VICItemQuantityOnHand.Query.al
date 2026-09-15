query 50453 "VIC Item Qty. On Hand"
{
    Caption = 'Item Quantity On Hand';
    QueryType = Normal;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter =
                Open = const(true);

            filter(ItemNoFilter; "Item No.")
            {
            }

            filter(LocationCodeFilter; "Location Code")
            {
            }

            column(RemainingQuantity; "Remaining Quantity")
            {
                Method = Sum;
            }
        }
    }
}