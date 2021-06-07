pageextension 50142 "Vicinity General Journal" extends "General Journal" //39
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
            field("Vicinity Line ID No."; Rec."Vicinity Line ID No.")
            {
                ApplicationArea = All;
            }
            field("Vicinity Event ID No."; Rec."Vicinity Event ID No.")
            {
                ApplicationArea = All;
            }
        }
    }
}