tableextension 90003 "VicinityItemJournalLine" extends "Item Journal Line" //MyTargetTableId 83
{
    fields
    {
        field(90000; "Vicinity Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = ToBeClassified;
        }
        field(90001; "Vicinity Facility ID"; Code[15])
        {
            Caption = 'Facility ID';
            DataClassification = ToBeClassified;
        }
        field(90002; "Vicinity Line ID No."; Integer)
        {
            Caption = 'Line ID No.';
            DataClassification = ToBeClassified;
        }
        field(90003; "Vicinity Event ID No."; Integer)
        {
            Caption = 'Event ID No.';
            DataClassification = ToBeClassified;

        }
        field(90004; "Called From Vicinity"; Boolean)
        {
            Caption = 'Called from Vicinity';
            DataClassification = ToBeClassified;

        }
    }

}