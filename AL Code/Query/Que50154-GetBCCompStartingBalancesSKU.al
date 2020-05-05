query 50154 GetBCCompStartingBalancesSKU
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentStartingBalancesSKU';
    EntitySetName = 'GetBCComponentStartingBalancesSKU';
    Caption = 'GetBCComponentStartingBalancesSKU';

    elements
    {
        dataitem(Stockkeeping_Unit; "Stockkeeping Unit")
        {
            column(LocationCode; "Location Code")
            {

            }
            column(LotSize; "Lot Size")
            {
                Method = Sum;
            }
            column(SafetyStockQuantity; "Safety Stock Quantity")
            {
                Method = Sum;
            }
            column(StandardCost; "Standard Cost")
            {
                Method = Max;
            }
            column(UnitCost; "Unit Cost")
            {
                Method = Max;
            }
            column(LastDirectCost; "Last Direct Cost")
            {
                Method = Max;
            }
        }
    }
}

