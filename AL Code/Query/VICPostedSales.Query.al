query 50163 VICPostedSales
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICPostedSales';
    EntitySetName = 'VICPostedSales';
    Caption = 'Vicinity Posted Sales';

    elements
    {
        dataitem(SIH; "Sales Invoice Header")
        {
            column(No_; "No.")
            { }
            column(Document_Number; "Order No.")
            { }
            column(Customer_Name; "Sell-to Customer Name")
            { }
            column(Customer_PO; "External Document No.")
            { }
            column(Ship_to_City; "Ship-to City")
            { }
            column(Ship_to_County; "Ship-to County")
            { }
            column(Country; "Ship-to Country/Region Code")
            { }
            column(Order_Date; "Order Date")
            { }
            column(Customer_Posting_Group; "Customer Posting Group")
            { }
            column(Gen_Bus_Posting_Group; "Gen. Bus. Posting Group")
            { }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            { }
            column(Ship_to_Code; "Ship-to Code")
            { }
            column(Document_Date; "Document Date")
            { }
            dataitem(SIL; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SIH."No.";
                column(Quantity_Base_; "Quantity (Base)")
                { }
                column(Shipment_Date; "Shipment Date")
                { }
                column(Item_No_; "No.")
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
                column(Line_No; "Line No.")
                { }
            }
        }
    }
}