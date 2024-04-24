query 50176 VICComponentStartingBalances
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICComponentStartingBalances';
    EntitySetName = 'VICComponentStartingBalances';
    Caption = 'Vicinity Component Starting Balances';

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

