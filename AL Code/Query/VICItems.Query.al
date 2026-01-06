query 50171 VICItems
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICItems';
    EntitySetName = 'VICItems';
    Caption = 'VICItems';

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
            column(GenProdPostingGroup; "Gen. Prod. Posting Group")
            {

            }
            column(InventoryPostingGroup; "Inventory Posting Group")
            {

            }
            column(ItemCategoryCode; "Item Category Code")
            {

            }

            column(Warehouse_Class_Code; "Warehouse Class Code")
            {

            }
            column(ReorderingPolicy; "Reordering Policy")
            {

            }
            column(SafetyLeadTime; "Safety Lead Time")
            {

            }
            column(SafetyStockQuantity; "Safety Stock Quantity")
            {

            }
            column(ReorderPoint; "Reorder Point")
            {

            }
            column(ReorderQuantity; "Reorder Quantity")
            {

            }
            column(MaximumInventory; "Maximum Inventory")
            {

            }
            column(MaximumOrderQuantity; "Maximum Order Quantity")
            {

            }
            column(MinimumOrderQuantity; "Minimum Order Quantity")
            {

            }

            column(VendorNo; "Vendor No.")
            {

            }

            column(VendorItemNo; "Vendor Item No.")
            {

            }

            column(SystemCreatedAt; "SystemCreatedAt")
            {
            }
            column(SystemModifiedAt; "SystemModifiedAt")
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
                DataItem(VendorNameLookup; Vendor)
                {
                    DataItemLink = "No." = Item."Vendor No.";
                    SqlJoinType = LeftOuterJoin;
                    column(VendorName; Name)
                    {
                    }
                }
            }
        }
    }
}
