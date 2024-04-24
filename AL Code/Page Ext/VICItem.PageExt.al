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

    var
        QtyOnBatchEndItem: Decimal;
        QtyOnBatchEndItemBOM: Decimal;
        QtyOnBatchIngredients: Decimal;
        QtyOnBatchByCoProducts: Decimal;
        QtyOnPlannedOrders: Decimal;
        VicinityATPFormsMgt: Codeunit "VICATPManagement";
        IsConfigured: Boolean;

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
        JSONUtilities: Codeunit VICJSONUtilities;
        PlanningItemQuantities: JsonObject;
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
