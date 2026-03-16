table 50170 "VICItemLots"
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Lot No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Remaining Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; ReservationEntryQuantityBase; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field (6; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field (7; "Expiration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Item No.", "Lot No.", "Location Code")
        {
        }
    }
}