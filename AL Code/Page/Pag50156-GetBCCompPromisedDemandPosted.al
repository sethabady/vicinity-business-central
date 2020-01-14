page 50156 GetBCCompPromisedDemandPosted
{

    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentPromisedDemandPosted';
    EntitySetName = 'GetBCComponentPromisedDemandPosted';
    DelayedInsert = true;
    SourceTable = "Sales Invoice Line";
    Caption = 'GetBCComponentPromisedDemandPosted';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("DocumentNo"; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("ItemNo"; "No.")
                {
                    ApplicationArea = All;
                }
                field("LocationCode"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("QuantityBase"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("ShipmentDate"; "Shipment Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
