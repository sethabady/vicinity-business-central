page 50182 VICBatchEndItemSubForm
{
    AutoSplitKey = true;
    Caption = 'End Items';
    LinksAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = VICBatchEndItem;
    //    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = true;
                // field("Facility ID"; Rec.FacilityId)
                // {
                //     ApplicationArea = All;
                // }
                // field("Batch Number"; rec.BatchNumber)
                // {
                //     ApplicationArea = All;
                // }
                field("Component ID"; rec.ComponentId)
                {
                    ApplicationArea = All;
                    Editable = false;
//                    CaptionClass = '10, GOOMBAH';
                }
                field("Description"; rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; rec.LocationCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; rec.BinCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Ordered"; rec.QuantityOrdered)
                {
                    Caption = 'Qty. Ordered';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Completed"; rec.QuantityCompleted)
                {
                    Caption = 'Qty. Completed';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Remaining"; rec.QuantityRemaining)
                {
                    Caption = 'Qty. Remaining';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. Unposted"; rec.QuantityUnposted)
                {
                    Caption = 'Qty. Unposted';
                    ApplicationArea = All;
                }
                field("Qty. to Complete"; rec.QuantityToComplete)
                {
                    Caption = 'Qty. to Complete';
                    ApplicationArea = All;
                }
                field("Unit of Measure"; rec.UnitOfMeasure)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Lot Number"; rec.LotNumber)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        BatchEndItemPostPage: Page VICBatchEndItemPost;

    trigger OnInit()
    var
        VICBatch: Record VICBatch;
        VICBatchEndItem: Record VICBatchEndItem;
    begin
        // VICBatch.Get(rec.FacilityId, rec.BatchNumber);
        // VICBatchEndItem.Init();
        //        VICBatchEndItem.FacilityId = 
    end;
}