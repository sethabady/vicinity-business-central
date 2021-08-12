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
                field("ItemNo"; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("LotSize"; Rec."Lot Size")
                {
                    ApplicationArea = All;
                }
                field("SafetyStockQuantity"; Rec."Safety Stock Quantity")
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec."SystemModifiedAt")
                {
                    ApplicationArea = All;
                }
                field("MinimumOrderQuantity"; Rec."Minimum Order Quantity")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}
