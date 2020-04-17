query 50151 GetBCLocationBins
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCLocationBins';
    EntitySetName = 'GetBCLocationBins';
    Caption = 'GetBCLocationBins';

    elements
    {
        /*
        Note: The following does not work correctly, so I changed this to use the Warehouse Entry instead
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Remaining Quantity" = filter(> 0), "Location Code" = filter(<> '');
            column(ItemNo; "Item No.")
            {

            }
            column(LocationCode; "Location Code")
            {
            }
            dataitem(Warehouse_Entry; "Warehouse Entry")
            {
                DataItemLink = "Item No." = Item_Ledger_Entry."Item No.", "Location Code" = Item_Ledger_Entry."Location Code";
                DataItemTableFilter = "Bin Code" = filter(<> '');
                SqlJoinType = InnerJoin;
                column(BinCode; "Bin Code")
                {
                }
                column(QtyBase; "Qty. (Base)")
                {
                    Method = Sum;
                }
            }
        }
        */

        // dataitem(Warehouse_Entry; "Warehouse Entry")
        // {
        //     column(ItemNo; "Item No.")
        //     {
        //     }
        //     column(LocationCode; "Location Code")
        //     {
        //     }
        //     column(BinCode; "Bin Code")
        //     {
        //     }
        //     column(SumQtyBase; "Qty. (Base)")
        //     {
        //         Method = Sum;
        //     }
        // }

        dataitem(Bin; "Bin")
        {
            column(LocationCode; "Location Code")
            {
            }
            column(BinCode; "Code")
            {
            }
        }
    }
}