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
    // ApplicationArea = All;
    // UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("DocumentNo"; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("ItemNo"; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("LocationCode"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("QuantityBase"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("ShipmentDate"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
