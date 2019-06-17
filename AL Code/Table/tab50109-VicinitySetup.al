table 50109 "Vicinity Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Vicinity Setup';
    LookupPageId = 50149;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(20; "Vicinity Enabled"; Boolean)
        {
            Caption = 'Vicinity Enabled';
            DataClassification = ToBeClassified;
        }
        field(30; "Warehousing Enabled"; Boolean)
        {
            Caption = 'Warehousing Enabled';
            DataClassification = ToBeClassified;
        }
        field(40; "Item Journal Batch"; Code[10])
        {
            Caption = 'Item Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name" = CONST ('ITEM'));
        }
        field(50; "Warehouse Journal Batch"; Code[10])
        {
            Caption = 'Warehouse Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Journal Batch".Name WHERE ("Journal Template Name" = CONST ('ADJMT'));
        }
        field(60; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(70; "Gen. Journal Batch"; Code[10])
        {
            Caption = 'Gen. Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = CONST ('GENERAL'));
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}