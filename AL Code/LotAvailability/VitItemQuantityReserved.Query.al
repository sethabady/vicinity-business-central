query 50454 "VIC Item Qty. Reserved"
{
    Caption = 'Item Quantity Reserved';
    QueryType = Normal;

    elements
    {
        dataitem(ReservationEntry; "Reservation Entry")
        {
            DataItemTableFilter =
                "Reservation Status" = const(Reservation),
                "Quantity (Base)" = filter(< 0);

            filter(ItemNoFilter; "Item No.")
            {
            }

            filter(LocationCodeFilter; "Location Code")
            {
            }

            column(QuantityBase; "Quantity (Base)")
            {
                Method = Sum;
            }
        }
    }
}