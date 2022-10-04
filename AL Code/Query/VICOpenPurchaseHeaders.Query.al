query 50174 VICOpenPurchaseHeaders
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICOpenPurchaseHeaders';
    EntitySetName = 'VICOpenPurchaseHeaders';
    Caption = 'Vicinity Open Purchase Headers';
    elements
    {
        dataitem(Purchase_Header; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = const(Order), Status = const(Open);
            column(No_;
            "No.")
            { }
            column(Document_Type; "Document Type")
            { }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.")
            { }
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name")
            { }
            column(Pay_to_Vendor_No_; "Pay-to Vendor No.")
            { }
            column(Pay_to_Name; "Pay-to Name")
            { }
            column(Pay_to_Contact; "Pay-to Contact")
            { }
            column(Ship_to_Code; "Ship-to Code")
            { }
            column(Ship_to_Name; "Ship-to Name")
            { }
            column(Ship_to_Contact; "Ship-to Contact")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Posting_Date; "Posting Date")
            { }
            column(Expected_Receipt_Date; "Expected Receipt Date")
            { }
            column(Due_Date; "Due Date")
            { }
            column(Shipment_Method_Code; "Shipment Method Code")
            { }
            column(Location_Code; "Location Code")
            { }
            column(Status; Status)
            { }
            column(SystemCreatedAt; SystemCreatedAt)
            { }
            column(SystemModifiedAt; SystemModifiedAt)
            { }
            column(SystemId; SystemId)
            { }
        }
    }
}
