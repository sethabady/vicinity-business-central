query 50150 GetBCComponents
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponents';
    EntitySetName = 'GetBCComponents';
    Caption = 'GetBCComponents';

    elements
    {
        dataitem(Item; Item)
        {
            column(ItemNo; "No.")
            {
            }
            column(Description; Description)
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
            column(BaseUnitofMeasure; "Base Unit of Measure")
            {
            }
            column(Type; Type)
            {
            }
            column(CostingMethod; "Costing Method")
            {
            }
            column(UnitPrice; "Unit Price")
            {

            }
            column(LeadTimeCalculation; "Lead Time Calculation")
            {

            }
            dataitem(ItemTracking; "Item Tracking Code")
            {
                DataItemLink = Code = Item."Item Tracking Code";
                SqlJoinType = LeftOuterJoin;
                column(ItemTrackingCode; Code)
                {

                }
                column(LotSpecificTracking; "Lot Specific Tracking")
                {
                }
            }
        }
    }
}

