query 50450 "VIC Lot Qty. On Hand"
{
    Caption = 'Lot Quantity On Hand';
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

            filter(LotNoFilter; "Lot No.")
            {
            }

            column(RemainingQuantity; "Remaining Quantity")
            {
                Method = Sum;
            }
        }
    }
}