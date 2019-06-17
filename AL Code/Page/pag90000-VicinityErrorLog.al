page 90000 "Vicinity Error Log"
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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = All;

                }
                field("Facility ID"; "Facility ID")
                {
                    ApplicationArea = All;

                }
                field("Line ID No."; "Line ID No.")
                {
                    ApplicationArea = All;

                }
                field("Event ID No."; "Event ID No.")
                {
                    ApplicationArea = All;

                }
                field("Error Date"; "Error Date")
                {
                    ApplicationArea = All;

                }
                field("Error Time"; "Error Time")
                {
                    ApplicationArea = All;

                }
                field("Error Text"; "Error Text")
                {
                    ApplicationArea = All;

                }
                field("Error Location"; "Error Location")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}