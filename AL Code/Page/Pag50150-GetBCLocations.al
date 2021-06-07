page 50150 GetBCLocations
{
    PageType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCLocations';
    EntitySetName = 'GetBCLocations';
    DelayedInsert = true;
    SourceTable = Location;
    Caption = 'GetBCLocations';
    ODataKeyFields = Code;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(LocationCode; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("DefaultBinCode"; Rec."Default Bin Code")
                {
                    ApplicationArea = All;
                }
                field("BinMandatory"; Rec."Bin Mandatory")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
