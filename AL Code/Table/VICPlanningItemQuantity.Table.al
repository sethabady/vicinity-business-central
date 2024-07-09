table 50419 VICPlanningItemQuantity
{
    DataClassification = ToBeClassified;
    TableType = Temporary;
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }

        field(5; "Entry No."; Integer)
        {
        }

        field(10; FacilityId; Text[15])
        {
            Caption = 'Facility ID';
            DataClassification = ToBeClassified;
        }

        field(20; DocumentNumber; Text[20])
        {
            Caption = 'Document Number';
            DataClassification = ToBeClassified;
        }

        field(30; QuantityType; Enum PlanningItemQuantityType)
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }

        field(40; TransactionDate; Date)
        {
            Caption = 'Start Date';
            DataClassification = ToBeClassified;
        }

        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; TransactionDate, FacilityId, DocumentNumber, QuantityType)
        {
        }
    }
}
