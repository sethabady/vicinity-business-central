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
                field("RequestedDeliveryDate"; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("ShipmentDate"; "Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("OutstandingQtyBase"; "Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
