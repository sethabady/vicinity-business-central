table 50412 VICProductionSchedule
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(10; ScheduleObjectId; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; ScheduleResourceObjectId; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(20; FacilityId; Code[15])
        {
            DataClassification = ToBeClassified;
            Caption = 'Facility ID';
        }
        field(30; OrderNumber; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Batch or Planned Order Number';
        }
        field(40; RecordType; Enum VICVisualObjectType)
        {
            DataClassification = ToBeClassified;
        }
        field(50; StartDateTime; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(60; EndDateTime; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(70; ComponentId; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(80; ComponentDescription; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90; FormulaId; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(100; FormulaDescription; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(110; IsABatch; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(120; ProcessCellId; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(130; FillUnitId; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(135; PlanningAttributeId; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(140; PlanningAttributeValue; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; ScheduleObjectId)
        {
            Clustered = true;
        }
        key(Key2; StartDateTime)
        {

        }
        key(Key3; EndDateTime)
        {

        }
        key(Key4; ScheduleResourceObjectId, StartDateTime)
        {

        }
        key(Key5; ScheduleResourceObjectId, EndDateTime)
        {

        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}