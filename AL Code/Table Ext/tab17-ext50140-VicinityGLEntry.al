tableextension 50140 "VicinityGLEntry" extends "G/L Entry" //MyTargetTableId 17
{
    fields
    {
        field(92250; "Vicinity Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(92251; "Vicinity Facility ID"; Code[15])
        {
            Caption = 'Facility ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(92252; "Vicinity Line ID No."; Integer)
        {
            Caption = 'Line ID No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(92253; "Vicinity Event ID No."; Integer)
        {
            Caption = 'Event ID No.';
            Editable = false;
            DataClassification = ToBeClassified;

        }
    }

}