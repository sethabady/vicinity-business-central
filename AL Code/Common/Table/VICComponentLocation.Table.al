table 50428 VICComponentLocation
{
    Caption = 'VICComponentLocation';
    TableType = Temporary;
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; ComponentId; Text[32])
        {
            Caption = 'Component ID';
        }
        field(2; LocationId; Text[15])
        {
            Caption = 'Location ID';
        }
        field(3; FormulaId; Text[32])
        {
            Caption = 'Formula ID';
        }
        field(4; FillQuantityPerStockingUnit; Decimal)
        {
            Caption = 'Fill Quantity Per Stocking Unit';
            DecimalPlaces = 0 : 5;
        }
        field(5; FillQuantityUnitOfMeasure; Text[20])
        {
            Caption = 'Fill Quantity Unit Of Measure';
        }
        field(6; FormulaSourceType; Enum FormulaSourceType)
        {
            Caption = 'Formula Source';
        }
        field(40; MachineId; Text[20])
        {
            Caption = 'Machine ID';
        }
        field(51; MachineCapacity; Decimal)
        {
            Caption = 'Machine Capacity';
            DecimalPlaces = 0 : 5;
        }
        field(52; MachineCapacityUnitOfMeasure; Code[10])
        {
            Caption = 'Machine Capacity Unit of Measure';
        }
    }
    keys
    {
        key(PK; ComponentId, LocationId)
        {
            Clustered = true;
        }
    }
}
