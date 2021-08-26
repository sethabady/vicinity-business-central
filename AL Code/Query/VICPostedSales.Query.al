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
            column(Document_Number; "Order No.")
            { }
            column(Customer_Name; "Sell-to Customer Name")
            { }
            column(Custumer_PO; "External Document No.")
            { }
            column(Ship_to_City; "Ship-to City")
            { }
            column(Ship_to_County; "Ship-to County")
            { }
            column(Country; "Ship-to Country/Region Code")
            { }
            column(Order_Date; "Order Date")
            { }
            dataitem(SIL; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SIH."No.";
                column(Quantity__Base_; "Quantity (Base)")
                { }
                column(Shipment_Date; "Shipment Date")
                { }
                column(Item_No_; "No.")
                { }
                column(SystemModifiedAt; SystemModifiedAt)
                { }
                column(SystemId; SystemId)
                { }
            }
        }
    }
}