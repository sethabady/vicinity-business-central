pageextension 50144 "Vicinity Value Entries" extends "Value Entries" //MyTargetPageId 5802
{
    layout
    {
        addlast(Control1)
        {
            field("Vicinity Batch No."; Rec."Vicinity Batch No.")
            {
                ApplicationArea = All;
            }
            field("Vicinity Facility ID"; Rec."Vicinity Facility ID")
            {
                ApplicationArea = All;
            }
            field("Line ID No."; Rec."Vicinity Line ID No.")
            {
                ApplicationArea = All;
            }
            field("Event ID No."; Rec."Vicinity Event ID No.")
            {
                ApplicationArea = All;
            }
        }
    }

}