query 50452 "VIC Lot Qty. Reserved"
{
    Caption = 'Lot Quantity Reserved';
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

            filter(LotNoFilter; "Lot No.")
            {
            }

            column(QuantityBase; "Quantity (Base)")
            {
                Method = Sum;
            }
        }
    }
}