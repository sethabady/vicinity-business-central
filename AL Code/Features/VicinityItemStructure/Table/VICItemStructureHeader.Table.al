table 50432 pte_vic_ItemStructureHeader
{
    Caption = 'Vicinity Item Structure';
    TableType = Temporary;
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ComponentId; Text[32])
        {
            Caption = 'Component ID';
            Editable = false;
        }
        field(2; DefaultFacilityId; Text[15])
        {
            Caption = 'Default Facility ID';
            Editable = false;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(10; UnitOfMeasure; Text[10])
        {
            Caption = 'Unit of measure';
            Editable = false;
        }





        field(3; FacilityId; Text[15])
        {
            Caption = 'Facility ID';
            Editable = false;
        }
        field(4; LineNo; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(5; LineType; Enum pte_vic_ItemStructLineType)
        {
            Caption = 'Line Type';
            Editable = false;
        }
        field(6; Id; Text[32])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(9; Level; Integer)
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

