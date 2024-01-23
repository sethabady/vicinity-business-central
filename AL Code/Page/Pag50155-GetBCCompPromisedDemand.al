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
    SourceTableView = where("Document Type" = filter(= "Order" | "Blanket Order" | "Invoice"), "Type" = const(Item));
    Caption = 'GetBCComponentPromisedDemand';
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
                field("RequestedDeliveryDate"; GetDemandDate())
                {
                    ApplicationArea = All;
                }
                // field("RequestedDeliveryDate"; Rec."Requested Delivery Date")
                // {
                //     ApplicationArea = All;
                // }
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

    // 20.1.0.0: if line dates are blank default to header dates. Requires 4.45 web services.
    local procedure GetDemandDate() DemandDate: Date
    var
        SalesHeader: Record "Sales Header";
    begin
        // Demand date is Requested Shipment Date so test its value first. Note that this is different than Independent Demand query.
        if Rec."Requested Delivery Date" <> 0D then
            exit(Rec."Requested Delivery Date");
        if Rec."Shipment Date" <> 0D then
            exit(Rec."Shipment Date");
        if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Document No.") then begin
            if SalesHeader."Requested Delivery Date" <> 0D then
                exit(SalesHeader."Requested Delivery Date");
            exit(SalesHeader."Order Date");
        end;
        exit(0D);
    end;
}
