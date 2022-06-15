query 50167 VICSalesCreditMemos
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICSalesCreditMemos';
    EntitySetName = 'VICSalesCreditMemos';
    Caption = 'Vicinity Sales Credit Memos';

    elements
    {
        dataitem(SCMH; "Sales Cr.Memo Header")
        {
            column(No_; "No.")
            { }
            column(Customer_Name; "Sell-to Customer Name")
            { }
            column(Customer_PO; "External Document No.")
            { }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            { }
            column(Ship_to_Code; "Ship-to Code")
            { }
            column(Ship_to_City; "Ship-to City")
            { }
            column(Ship_to_County; "Ship-to County")
            { }
            column(Country; "Ship-to Country/Region Code")
            { }
            column(Document_Date; "Document Date")
            { }
            column(Customer_Posting_Group; "Customer Posting Group")
            { }
            column(Gen_Bus_Posting_Group; "Gen. Bus. Posting Group")
            { }
            dataitem(SCML; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = SCMH."No.";
                column(Line_No; "Line No.")
                { }
                column(Quantity_Base_; "Quantity (Base)")
                { }
                column(Item_No; "No.")
                { }
                column(Location_Code; "Location Code")
                {

                }
                column(Shipment_Date; "Shipment Date")
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