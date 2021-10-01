query 50164 VICTransfers
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICTransfers';
    EntitySetName = 'VICTransfers';
    Caption = 'Vicinity Transfers';

    elements
    {
        dataitem(TH; "Transfer Header")
        {
            column(No_; "No.")
            { }
            column(Transfer_from_Code; "Transfer-from Code")
            { }
            column(Transfer_to_Code; "Transfer-to Code")
            { }
            column(Receipt_Date; "Receipt Date")
            { }
            column(Shipment_Date; "Shipment Date")
            { }
            dataitem(Transfer_Line; "Transfer Line")
            {
                DataItemLink = "Document No." = TH."No.";
                column(Item_No; "Item No.")
                { }
                column(Outstanding_Qty_Base; "Outstanding Qty. (Base)")
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