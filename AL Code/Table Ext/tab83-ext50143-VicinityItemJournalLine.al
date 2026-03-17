tableextension 50143 "VicinityItemJournalLine" extends "Item Journal Line" //MyTargetTableId 83
{
    fields
    {
        field(92250; "Vicinity Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = ToBeClassified;
        }
        field(92251; "Vicinity Facility ID"; Code[15])
        {
            Caption = 'Facility ID';
            DataClassification = ToBeClassified;
        }
        field(92252; "Vicinity Line ID No."; Integer)
        {
            Caption = 'Line ID No.';
            DataClassification = ToBeClassified;
        }
        field(92253; "Vicinity Event ID No."; Integer)
        {
            Caption = 'Event ID No.';
            DataClassification = ToBeClassified;

        }
        field(92254; "Called From Vicinity"; Boolean)
        {
            Caption = 'Called from Vicinity';
            DataClassification = ToBeClassified;

        }
        field(92255;VICBatchItemJournalSourceType; Enum VICBatchItemJournalSourceType)
        {
            Caption = 'Vicinity Batch Source';
            DataClassification = ToBeClassified;

        }
        field(90006; "VIC Quantity Remaining"; Decimal)
        {
            Caption = 'VIC Quantity Remaining';
            DataClassification = ToBeClassified;
        }
    }
}