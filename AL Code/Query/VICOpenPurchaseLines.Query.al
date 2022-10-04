query 50175 VICOpenPurchaseLines
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICOpenPurchaseLines';
    EntitySetName = 'VICOpenPurchaseLines';
    Caption = 'Vicinity Open Purchase Lines';

    elements
    {
        dataitem(Purchase_Header; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = const(Order), Status = const(Open);
            column(No_; "No.")
            { }
            DataItem(Purchase_Line; "Purchase Line")
            {
                DataItemLink = "Document No." = Purchase_Header."No.";
                column(Item_No; "No.")
                { }
                column(Location_Code; "Location Code")
                { }
                column(Quantity_Base; "Quantity (Base)")
                { }
                column(Outstanding_Qty__Base_; "Outstanding Qty. (Base)")
                { }
                column(Expected_Receipt_Date; "Expected Receipt Date")
                { }
                column(Order_Date; "Order Date")
                { }
                column(Planned_Receipt_Date; "Planned Receipt Date")
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
}
