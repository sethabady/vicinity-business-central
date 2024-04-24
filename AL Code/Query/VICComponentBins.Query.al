query 50173 VICComponentBins
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICComponentBins';
    EntitySetName = 'VICComponentBins';
    Caption = 'Vicinity Component Bins';

    elements
    {
        dataitem(Warehouse_Entry; "Warehouse Entry")
        {
            column(ItemNo; "Item No.")
            {
            }
            column(LocationCode; "Location Code")
            {
            }
            column(BinCode; "Bin Code")
            {
            }
            column(LotNo; "Lot No.")
            {
            }
            column(SumQtyBase; "Qty. (Base)")
            {
                Method = Sum;
            }
        }
    }
}

