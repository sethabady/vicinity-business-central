table 50413 VICFormula
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(10; FormulaId; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Description; Text[60])
        {
            DataClassification = ToBeClassified;
        }
        field(20; ScheduleObjectId; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(25; ScheduleResourceObjectId; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; FormulaId)
        {
            Clustered = true;
        }
        key(Key2; Description)
        {

        }
    }
}
