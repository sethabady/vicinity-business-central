pageextension 50143 "Vicinity Item Journal" extends "Item Journal" //MyTargetPageId 40
{
    layout
    {
        addlast(Control1)
        {
            field("Vicinity Batch No."; "Vicinity Batch No.")
            {
                ApplicationArea = All;
            }
            field("Vicinity Facility ID"; "Vicinity Facility ID")
            {
                ApplicationArea = All;
            }
            field("Vicinity Line ID No."; "Vicinity Line ID No.")
            {
                ApplicationArea = All;
            }
            field("Vicinity Event ID No."; "Vicinity Event ID No.")
            {
                ApplicationArea = All;
            }
        }
    }

}