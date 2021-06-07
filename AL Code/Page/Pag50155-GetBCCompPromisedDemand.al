page 50155 GetBCCompPromisedDemand
{

    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentPromisedDemand';
    EntitySetName = 'GetBCComponentPromisedDemand';
    DelayedInsert = true;
    SourceTable = "Sales Line";
    Caption = 'GetBCComponentPromisedDemand';
    ApplicationArea = All;
    UsageCategory = Lists;
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
                field("RequestedDeliveryDate"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("ShipmentDate"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("OutstandingQtyBase"; Rec."Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
