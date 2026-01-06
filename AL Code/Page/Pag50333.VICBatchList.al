page 50333 VICBatchListTemp
{
    ApplicationArea = All;
    Caption = 'VICBatchList';
    PageType = List;
    UsageCategory = None; // Lists; DEVELOPMENT
    SourceTable = VICBatch;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(FacilityId; Rec.FacilityId)
                {
                    ToolTip = 'Specifies the value of the Facility ID field.', Comment = '%';
                }
                field(BatchNumber; Rec.BatchNumber)
                {
                    ToolTip = 'Specifies the value of the Batch Number field.', Comment = '%';
                }
                field(BatchDescription; Rec.BatchDescription)
                {
                    ToolTip = 'Specifies the value of the Batch Description field.', Comment = '%';
                }
                field(FormulaId; Rec.FormulaId)
                {
                    ToolTip = 'Specifies the value of the Formula ID field.', Comment = '%';
                }
                field(PlanStartDate; Rec.PlanStartDate)
                {
                    ToolTip = 'Specifies the value of the Plan Start Date field.', Comment = '%';
                }
            }
        }
    }
}
