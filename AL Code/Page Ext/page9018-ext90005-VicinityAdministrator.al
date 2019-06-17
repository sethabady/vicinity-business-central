pageextension 90005 "Vicinity Administrator" extends "Administrator Role Center" //MyTargetPageId 9018
{
    Actions
    {
        addafter("Data Privacy")
        {
            group(Vicinity)

            {
                Action(VicinitySetup)
                {
                    ApplicationArea = All;
                    Caption = 'Vicinity Setup';
                    RunObject = page "Vicinity Setup";

                }

                Action(VicinityErrorLog)
                {
                    ApplicationArea = All;
                    Caption = 'Vicinity Error Log';
                    RunObject = page "Vicinity Error Log";
                }
                /*
                Action(VicinityTest)
                {
                    ApplicationArea = All;
                    Caption = 'Vicinity Test';
                    RunObject = codeunit "Vicinity Test Codeunit";
                }
                */
            }
        }

    }
}
