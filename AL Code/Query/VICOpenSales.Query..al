query 50162 VICOpenSales
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICOpenSales';
    EntitySetName = 'VICOpenSales';
    Caption = 'Vicinity Open Sales';

    elements
    {
        dataitem(SH; "Sales Header")
        {
            column(Document_Number; "No.")
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
            dataitem(SL; "Sales Line")
            {
                DataItemLink = "Document No." = SH."No.";
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
