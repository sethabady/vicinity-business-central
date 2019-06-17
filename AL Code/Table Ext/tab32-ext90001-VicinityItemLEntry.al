tableextension 90001 "VicinityItemLEntry" extends "Item Ledger Entry" //MyTargetTableId 32
{
    fields
    {
        field(90000; "Vicinity Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90001; "Vicinity Facility ID"; Code[15])
        {
            Caption = 'Facility ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90002; "Vicinity Line ID No."; Integer)
        {
            Caption = 'Line ID No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90003; "Vicinity Event ID No."; Integer)
        {
            Caption = 'Event ID No.';
            Editable = false;
            DataClassification = ToBeClassified;

        }
    }
    keys
    {
        key(key1; "Vicinity Batch No.", "Vicinity Facility ID", "Vicinity Line ID No.", "Vicinity Event ID No.")
        {

        }
    }

}