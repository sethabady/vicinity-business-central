pageextension 50146 VICAvailableToPromise extends "Sales Order Subform"
{
    actions
    {
        addfirst("Item Availability by")
        {
            action(VicinityATP)
            {
                ApplicationArea = All;
                Visible = isConfigured;
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
        isConfigured: Boolean;

    trigger OnOpenPage()
    var
        VicinitySetup: Record "Vicinity Setup";
    begin
        isConfigured := false;
        if VicinitySetup.Get() 
        then begin
            isConfigured := StrLen(VicinitySetup.ApiUrl) > 0;
        end;
    end;
}
