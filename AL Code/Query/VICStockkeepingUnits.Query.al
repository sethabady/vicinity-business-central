query 50172 VICStockkeepingUnits
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICStockkeepingUnits';
    EntitySetName = 'VICStockkeepingUnits';
    Caption = 'VICStockkeepingUnits';

    elements
    {
        dataitem(Stockkeeping_Unit; "Stockkeeping Unit")
        {
            // Include ItemNo, LocationCode, VariantCode. Data will be aggregate by those fields.
            column(ItemNo; "Item No.")
            {

            }
            column(LocationCode; "Location Code")
            {

            }
            column(VariantCode; "Variant Code")
            {

            }
            column(LotSize; "Lot Size")
            {

            }
            column(SafetyStockQuantity; "Safety Stock Quantity")
            {

            }
            column(StandardCost; "Standard Cost")
            {

            }
            column(UnitCost; "Unit Cost")
            {

            }
            column(LastDirectCost; "Last Direct Cost")
            {

            }
            // V4-2274
            column(SafetyLeadTime;"Safety Lead Time")
            {

            }
            column(LeadTimeCalculation; "Lead Time Calculation")
            {

            }
            column(SystemCreatedAt; "SystemCreatedAt")
            {
            }
            column(SystemModifiedAt; "SystemModifiedAt")
            {
            }
        }
    }
}


