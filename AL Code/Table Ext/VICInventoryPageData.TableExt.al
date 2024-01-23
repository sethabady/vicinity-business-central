tableextension 50147 "VICInventoryPageData" extends "Inventory Page Data"
{
    fields
    {
        field(90000; "VicinityDocument"; Code[20])
        {
            Caption = 'Batch No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90001; "FacilityId"; Code[15])
        {
            Caption = 'Facility ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }

        field(90002; "VicinityEntityType"; Integer)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
}
