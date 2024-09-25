pageextension 50147 VICItem extends "Item Card"
{
    layout
    {
        addbefore("Costs & Posting")
        {
            group(Vicinity)
            {
                Visible = IsConfigured;
                field("Qty. on Batch End Items"; QtyOnBatchEndItem)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field("Qty. on Batch BOM"; QtyOnBatchEndItemBOM)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field("Qty. on Batch Ingredients"; QtyOnBatchIngredients)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field("Qty. on Batch By/Co-Products"; QtyOnBatchByCoProducts)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field("Qty. on Firm Planned Orders"; QtyOnPlannedOrders)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
            }
        }
    }

    actions
    {
        addlast(Promoted)
        {
            actionref(VicinityItemInfoRef; VicinityItemInfo)
            {
            }
        }

        addlast(Functions)
        {
            action(VicinityItemInfo)
            {
                ApplicationArea = All;
                Visible = true;
                Caption = 'Vicinity Item Details';
                Image = AvailableToPromise;
                trigger OnAction();
                var
                    VICPlanningItemDetailsPage: Page VICPlanningItemDetails;
                    PlanningItemQuantitiesDetails: JsonToken;
                    PlanningItemQuantitiesDetailsArray: JsonArray;

                    // V4-2152: Used Item Card as test harness.
                    // VICRequisitionService: Codeunit VICRequisitionService;
                    // VicinityRequisitions: JsonArray;
                    // VicinityRequisition: JsonObject;
                begin
                    // // Initialize the json object. -- for testing requisitions
                    // VicinityRequisition.Add('ComponentId', Rec."No.");
                    // VicinityRequisition.Add('LocationCode', 'WAREHOUSE');
                    // VicinityRequisition.Add('Quantity', 110);
                    // VicinityRequisition.Add('DueDate', CurrentDateTime);
                    // VicinityRequisitions.Add(VicinityRequisition);
                    // Message(VICRequisitionService.AddToWorksheet('REQ.', 'VICINITY', true, VicinityRequisitions));

                    if not PlanningItemQuantities.AsToken().SelectToken('[' + '''' + 'PlanningItemQuantityDetails' + '''' + ']', PlanningItemQuantitiesDetails) then
                        exit;
                    PlanningItemQuantitiesDetailsArray := PlanningItemQuantitiesDetails.AsArray();
                    VICPlanningItemDetailsPage.SetItem(Rec);
                    VICPlanningItemDetailsPage.SetPlanningItemDetails(PlanningItemQuantitiesDetailsArray);
                    VICPlanningItemDetailsPage.LookupMode := true;
                    if VICPlanningItemDetailsPage.RunModal = ACTION::LookupOK then begin end;
                end;
            }
        }
    }

    var
        QtyOnBatchEndItem: Decimal;
        QtyOnBatchEndItemBOM: Decimal;
        QtyOnBatchIngredients: Decimal;
        QtyOnBatchByCoProducts: Decimal;
        QtyOnPlannedOrders: Decimal;
        VicinityATPFormsMgt: Codeunit "VICATPManagement";
        IsConfigured: Boolean;
        VICPlanningItemQuantity: Record VICPlanningItemQuantity temporary;
        PlanningItemQuantities: JsonObject;
        JSONUtilities: Codeunit VICJSONUtilities;
        VICJsonUtilities: Codeunit VICJSONUtilities;

    trigger OnOpenPage()
    var
        VicinitySetup: Record "Vicinity Setup";
    begin
        QtyOnBatchEndItem := 100;
        IsConfigured := false;
        if VicinitySetup.Get()
        then begin
            IsConfigured := StrLen(VicinitySetup.ApiUrl) > 0;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        ProductionScheduleManagement: Codeunit VICProdScheduleManagement;
    begin
        if IsConfigured then begin
            PlanningItemQuantities := ProductionScheduleManagement.FetchPlanningItemQuantitiesFromWebApi(rec."No.");
            QtyOnBatchEndItem := JSONUtilities.GetDecimalFromJson(PlanningItemQuantities.AsToken(), 'TotalQuantityOnBatchEndItem');
            QtyOnBatchEndItemBOM := JSONUtilities.GetDecimalFromJson(PlanningItemQuantities.AsToken(), 'TotalQuantityOnBatchEndItemBOM');
            QtyOnBatchIngredients := JSONUtilities.GetDecimalFromJson(PlanningItemQuantities.AsToken(), 'TotalQuantityOnBatchIngredients');
            QtyOnBatchByCoProducts := JSONUtilities.GetDecimalFromJson(PlanningItemQuantities.AsToken(), 'TotalQuantityOnBatchByCoProducts');
            QtyOnPlannedOrders := JSONUtilities.GetDecimalFromJson(PlanningItemQuantities.AsToken(), 'TotalQuantityOnPlannedOrders');
        end;
    end;
}
