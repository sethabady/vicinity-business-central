page 50153 GetBCLocationBins
{

    PageType = List;
    SourceTable = Bin;
    Caption = 'GetBCLocationBins';
    ApplicationArea = All;
    UsageCategory = Lists;
    ODataKeyFields = Code;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Bin Type Code"; "Bin Type Code")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Class Code"; "Warehouse Class Code")
                {
                    ApplicationArea = All;
                }
                field("Block Movement"; "Block Movement")
                {
                    ApplicationArea = All;
                }
                field("Special Equipment Code"; "Special Equipment Code")
                {
                    ApplicationArea = All;
                }
                field("Bin Ranking"; "Bin Ranking")
                {
                    ApplicationArea = All;
                }
                field("Adjustment Bin"; "Adjustment Bin")
                {
                    ApplicationArea = All;
                }
                field("Cross-Dock Bin"; "Cross-Dock Bin")
                {
                    ApplicationArea = All;
                }
                field("Maximum Cubage"; "Maximum Cubage")
                {
                    ApplicationArea = All;
                }
                field("Maximum Weight"; "Maximum Weight")
                {
                    ApplicationArea = All;
                }
                field(Empty; Empty)
                {
                    ApplicationArea = All;
                }
                field(Dedicated; Dedicated)
                {
                    ApplicationArea = All;
                }
                field(Default; Default)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
