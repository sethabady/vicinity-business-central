pageextension 50146 VICAvailableToPromise extends "Sales Order Subform"
{
    actions
    {
        addfirst("Item Availability by")
        {
            action(VicinityATP)
            {
                ApplicationArea = All;
                Caption = 'Vicinity Available to Promise';
                Image = AvailableToPromise;
                trigger OnAction();
                begin
                    VicinityATPFormsMgt.ShowATPPage(Rec);
                end;
            }
        }
    }

    var
        VicinityATPFormsMgt: Codeunit "VICATPManagement";
}
