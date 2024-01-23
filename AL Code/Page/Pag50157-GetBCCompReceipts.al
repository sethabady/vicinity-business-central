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

    // V4-2120
    SourceTableView = where("Document Type" = const(Order), "Type" = const(Item));
    Caption = 'GetBCComponentReceipts';
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
                field("ExpectedReceiptDate"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("OrderDate"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("OutstandingQtyBase"; Rec."Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
