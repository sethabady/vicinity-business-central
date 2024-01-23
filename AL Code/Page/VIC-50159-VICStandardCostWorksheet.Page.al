page 50159 VICStandardCostWorksheet
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICStandardCostWorksheet';
    EntitySetName = 'VICStandardCostWorksheet';
    DelayedInsert = true;
    SourceTable = "Standard Cost Worksheet";
    Caption = 'VICStandardCostWorksheet';
    // ApplicationArea = All;
    // UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(WorksheetName; Rec."Standard Cost Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field(NewStandardCost; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}