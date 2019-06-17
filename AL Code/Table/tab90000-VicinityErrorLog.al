table 90000 "Vicinity Error Log"
{
    DataClassification = ToBeClassified;
    Caption = 'Vicinity Error Log';
    LookupPageId = 90000;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = ToBeClassified;
        }
        field(30; "Facility ID"; Code[15])
        {
            Caption = 'Facility ID';
            DataClassification = ToBeClassified;
        }
        field(40; "Line ID No."; Integer)
        {
            Caption = 'Line ID No.';
            DataClassification = ToBeClassified;
        }
        field(50; "Event ID No."; Integer)
        {
            Caption = 'Event ID No.';
            DataClassification = ToBeClassified;
        }
        field(60; "Error Date"; Date)
        {
            Caption = 'Error Date';
            DataClassification = ToBeClassified;
        }
        field(70; "Error Time"; Time)
        {
            Caption = 'Error Time';
            DataClassification = ToBeClassified;
        }
        field(80; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            DataClassification = ToBeClassified;
        }
        field(90; "Error Location"; Text[50])
        {
            Caption = 'Error Location';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}