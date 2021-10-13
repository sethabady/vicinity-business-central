query 50165 VICSalesShipments
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICSalesShipments';
    EntitySetName = 'VICSalesShipments';
    Caption = 'Vicinity Sales Shipments';

    elements
    {
        dataitem(SSH; "Sales Shipment Header")
        {
            column(No_; "No.")
            { }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            { }
            column(Ship_to_Code; "Ship-to Code")
            { }
            column(Ship_to_Name; "Ship-to Name")
            { }
            column(Ship_to_Name_2; "Ship-to Name 2")
            { }
            column(Ship_to_Address; "Ship-to Address")
            { }
            column(Ship_to_Address_2; "Ship-to Address 2")
            { }
            column(Ship_to_City; "Ship-to City")
            { }
            column(Ship_to_County; "Ship-to County")
            { }
            column(Ship_to_Post_Code; "Ship-to Post Code")
            { }
            column(Ship_to_Country_Region_Code; "Ship-to Country/Region Code")
            { }
            column(Document_Date; "Document Date")
            { }
            column(Customer_Posting_Group; "Customer Posting Group")
            { }
            column(Gen_Bus_Posting_Group; "Gen. Bus. Posting Group")
            { }
            dataitem(SSL; "Sales Shipment Line")
            {
                DataItemLink = "Document No." = SSH."No.";
                column(Line_No; "Line No.")
                { }
                column(Item_No; "No.")
                { }
                column(Quantity__Base_; "Quantity (Base)")
                { }
                column(Location_Code; "Location Code")
                { }
                column(SystemCreatedAt; SystemCreatedAt)
                { }
                column(SystemModifiedAt; SystemModifiedAt)
                { }
                column(SystemId; SystemId)
                { }
                column(Gen_Prod_Posting_Group; "Gen. Prod. Posting Group")
                { }
            }
        }
    }
}
