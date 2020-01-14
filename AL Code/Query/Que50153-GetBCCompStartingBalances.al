query 50153 GetBCCompStartingBalances
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentStartingBalances';
    EntitySetName = 'GetBCComponentStartingBalances';
    Caption = 'GetBCComponentStartingBalances';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(ItemNo; "Item No.")
            {

            }
            column(LocationCode; "Location Code")
            {

            }
            column(RemainingQuantity; "Remaining Quantity")
            {
                Method = Sum;
            }
        }
    }
}

