table 50429 VICItemStructurePageData
{
    Caption = 'Vicinity Item Structure Page Data';
    TableType = Temporary;
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ComponentId; Text[32])
        {
            Caption = 'Component ID';
            Editable = false;
        }
        field(2; FacilityId; Text[15])
        {
            Caption = 'Facility ID';
            Editable = false;
        }
        field(3; LineNo; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(4; LineType; Enum VICItemStructureLineType)
        {
            Caption = 'Line Type';
            Editable = false;
        }
        field(5; Id; Text[32])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(8; Level; Integer)
        {
            Caption = 'Level';
            Editable = false;
        }
    }
    keys
    {
        key(PK; ComponentId, FacilityId, LineNo)
        {
            Clustered = true;
        }
    }
}
