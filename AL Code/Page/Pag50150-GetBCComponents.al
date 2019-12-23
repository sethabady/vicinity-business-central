page 50150 GetBCComponents
{
    PageType = List;
    SourceTable = "BOM Component";
    Caption = 'GetBCComponents';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = "Parent Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Parent Item No."; "Parent Item No.")
                {
                    ApplicationArea = All;
                }
                field("BOM Description"; "BOM Description")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Assembly BOM"; "Assembly BOM")
                {
                    ApplicationArea = All;
                }
                field("Quantity per"; "Quantity per")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Installed in Item No."; "Installed in Item No.")
                {
                    ApplicationArea = All;
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
                field("Position 2"; "Position 2")
                {
                    ApplicationArea = All;
                }
                field("Position 3"; "Position 3")
                {
                    ApplicationArea = All;
                }
                field("Machine No."; "Machine No.")
                {
                    ApplicationArea = All;
                }
                field("Lead-Time Offset"; "Lead-Time Offset")
                {
                    ApplicationArea = All;
                }
                field("Resource Usage Type"; "Resource Usage Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
