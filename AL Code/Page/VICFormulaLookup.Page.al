page 50431 "VICFormulaLookup"
{
    PageType = List;
    SourceTable = "VICFormulaLookup";
    SourceTableTemporary = true;

    ApplicationArea = All;
    UsageCategory = None; // lookup pages usually aren't in search
    Caption = 'Select Formula';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OK)
            {
                Caption = 'OK';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
}
