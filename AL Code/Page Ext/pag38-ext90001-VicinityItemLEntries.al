pageextension 90001 "Vicinity Item Entries" extends "Item Ledger Entries" //MyTargetPageId 38
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
            field("Line ID No."; "Vicinity Line ID No.")
            {
                ApplicationArea = All;
            }
            field("Event ID No."; "Vicinity Event ID No.")
            {
                ApplicationArea = All;
            }
        }
    }

}