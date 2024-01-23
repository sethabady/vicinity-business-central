page 50221 VICDrillbackSetup
{
    ApplicationArea = All;
    Caption = 'Vicinity Drillbacks';
    PageType = List;
    SourceTable = "VICDrillback";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(drillbackId; Rec."Drillback ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique ID of the drillback.';
                }
                field(vicinityScreen; Rec."Vicinity Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vicinity target screen.';
                }
                field(drillbackHyperLink; Rec."Drillback Hyperlink")
                {
                    ApplicationArea = All;
                    ToolTip = 'The drillback hyperlink.';
                }
            }
        }
    }

    actions
    {
    }


    var
}
