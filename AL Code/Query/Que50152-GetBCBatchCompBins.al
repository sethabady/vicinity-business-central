query 50152 GetBCBatchCompBins
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCBatchComponentBins';
    EntitySetName = 'GetBCBatchComponentBins';
    Caption = 'GetBCBatchComponentBins';

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
            column(RegisteringDate; "Registering Date")
            {
            }
            column(SumQtyBase; "Qty. (Base)")
            {
                ColumnFilter = SumQtyBase = FILTER(<> 0);
                Method = Sum;
            }
        }
    }
}

