page 50148 "Vicinity Error Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Vicinity Error Log";
    Caption = 'Vicinity Error Log';
    Editable = False;



    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;

                }
                field("Facility ID"; Rec."Facility ID")
                {
                    ApplicationArea = All;

                }
                field("Line ID No."; Rec."Line ID No.")
                {
                    ApplicationArea = All;

                }
                field("Event ID No."; Rec."Event ID No.")
                {
                    ApplicationArea = All;

                }
                field("Error Date"; Rec."Error Date")
                {
                    ApplicationArea = All;

                }
                field("Error Time"; Rec."Error Time")
                {
                    ApplicationArea = All;

                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = All;

                }
                field("Error Location"; Rec."Error Location")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}