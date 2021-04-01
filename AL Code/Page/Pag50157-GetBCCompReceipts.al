page 50157 GetBCCompReceipts
{

    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCComponentReceipts';
    EntitySetName = 'GetBCComponentReceipts';
    DelayedInsert = true;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const(1));
    Caption = 'GetBCComponentReceipts';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("DocumentNo"; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("ItemNo"; "No.")
                {
                    ApplicationArea = All;
                }
                field("LocationCode"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("ExpectedReceiptDate"; "Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("OrderDate"; "Order Date")
                {
                    ApplicationArea = All;
                }
                field("OutstandingQtyBase"; "Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
