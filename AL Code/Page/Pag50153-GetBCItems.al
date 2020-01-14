page 50153 GetBCItems
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCItems';
    EntitySetName = 'GetBCItems';
    DelayedInsert = true;
    SourceTable = "Item";
    Caption = 'GetBCItems';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ItemNo"; "No.")
                {
                    ApplicationArea = All;
                }
                field("LotSize"; "Lot Size")
                {
                    ApplicationArea = All;
                }
                field("SafetyStockQuantity"; "Safety Stock Quantity")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
