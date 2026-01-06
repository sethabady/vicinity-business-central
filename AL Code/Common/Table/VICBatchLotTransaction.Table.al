table 50427 VICBatchLotTransaction
{
    DataClassification = ToBeClassified;
    Caption = 'Batch Lot Transaction';
    TableType = Temporary;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            NotBlank = true;
            Editable = false;       // Optional: prevent editing on pages
        }
        field(2; LineIdNumber; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line ID Number';
        }
        field(3; LotNumber; Code[50])
        {
            Caption = 'Lot Number';
            Editable = true ;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = true ;
        }
    }
    keys
    {
        key(PK; "Entry No.", LineIdNumber)
        {
            Clustered = true;
        }
        key(Key1; "LineIdNumber")
        {}
    }
}
