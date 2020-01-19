page 50160 BCCust
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'BCCust';
    EntitySetName = 'BCCust';
    DelayedInsert = true;
    SourceTable = "Customer";
    Caption = 'BCCust';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("CustNo"; "No.")
                {
                    ApplicationArea = All;
                }
                field("CustName"; Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
