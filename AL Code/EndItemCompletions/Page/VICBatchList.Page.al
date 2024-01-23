page 50180 VICBatchList
{
    Caption = 'Vicinity End-Item Completions';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = VICBatch;
    CardPageId = VICBatchEndItemPost;
    SourceTableView = sorting(BatchNumber, FacilityId) order(ascending);
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch Number"; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                }
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = All;
                }
                field("Batch Descripton"; Rec.BatchDescription)
                {
                    ApplicationArea = All;
                }
                field("Processing Stage"; Rec.ProcessingStage)
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Plan Start Date"; Rec.PlanStartDate)
                {
                    ApplicationArea = All;
                }
                field("Plan End Date"; Rec.PlanEndDate)
                {
                    ApplicationArea = All;
                }
                field("Actual Start Date"; Rec.ActualStartDate)
                {
                    ApplicationArea = All;
                }
                field("Actual End Date"; Rec.ActualEndDate)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInit()
    var
        VICWebServiceInterface: Codeunit VICWebApiInterface;
        VicinitySetup: Record "Vicinity Setup";
    begin
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(VicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        VICWebServiceInterface.OnFetchBatchSummaries();
    end;
}