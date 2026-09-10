query 50451 "VIC Bin Qty. On Hand"
{
    Caption = 'Bin Quantity On Hand';
    QueryType = Normal;

    elements
    {
        dataitem(WarehouseEntry; "Warehouse Entry")
        {
            filter(ItemNoFilter; "Item No.")
            {
            }

            filter(LocationCodeFilter; "Location Code")
            {
            }

            filter(BinCodeFilter; "Bin Code")
            {
            }

            filter(LotNoFilter; "Lot No.")
            {
            }

            column(QuantityBase; "Qty. (Base)")
            {
                Method = Sum;
            }
        }
    }
}