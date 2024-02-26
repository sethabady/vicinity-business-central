page 50154 GetBCCompIndependentDemand
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentIndependentDemand';
    EntitySetName = 'GetBCComponentIndependentDemand';
    DelayedInsert = true;
    SourceTable = "Sales Line";
    //SourceTableView = WHERE("Type"=const(Item), "Shipment Date"=filter(<> 0D));

    // V4-2120
//    SourceTableView = where("Document Type" = filter(<> "Return Order"), "Type" = const(Item));
    SourceTableView = where("Document Type" = filter(= "Order" | "Blanket Order" | "Invoice"), "Type" = const(Item));
    Caption = 'GetBCComponentIndependentDemand';
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
                field("RequestedDeliveryDate"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("ShipmentDate"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                // field("ShipmentDate"; GetDemandDate())
                // {
                //     ApplicationArea = All;
                // }
                field("OutstandingQtyBase"; Rec."Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // V4-2120 (20.0.1.3) : if line dates are blank default to header dates.
    local procedure GetDemandDate() DemandDate: Date
    var
        SalesHeader: Record "Sales Header";
    begin
        // Demand date is Shipment Date so test its value first.
        if Rec."Shipment Date" <> 0D then
            exit(Rec."Shipment Date");
        if Rec."Requested Delivery Date" <> 0D then
            exit(Rec."Requested Delivery Date");
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then begin
            if SalesHeader."Requested Delivery Date" <> 0D then
                exit(SalesHeader."Requested Delivery Date");
            exit(SalesHeader."Order Date");
        end;
        exit(0D);
    end;
}