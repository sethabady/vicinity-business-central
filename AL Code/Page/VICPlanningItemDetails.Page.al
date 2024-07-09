page 50147 "VICPlanningItemDetails"
{
    Caption = 'Vicinity Item Details';
    DataCaptionExpression = ATPPageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = VICPlanningItemQuantity;
    SourceTableTemporary = true;
    SourceTableView = SORTING("TransactionDate", "FacilityId", "DocumentNumber", "QuantityType")
                       ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Control5)
            {
                Editable = false;
                field("Date"; Rec.TransactionDate)
                {
                    Caption = 'Date';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the plan start date of the document line.';
                    Visible = true;
                    trigger OnDrillDown()
                    var
                        DrillDown: Text;
                        VICDrillDownUtilities: Codeunit VICDrillDownUtilities;
                    begin
                        DrillDown := VICDrillDownUtilities.GetDrillDownHyperlink(Rec.QuantityType, Rec.FacilityId, Rec.DocumentNumber);
                        if Format(DrillDown) <> '' then
                            Hyperlink((DrillDown));
                    end;
                }
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the facility of the document line.';
                }
                field("Document Number"; Rec.DocumentNumber)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the batch or planned order number of the line.';

                    trigger OnDrillDown()
                    var
                        DrillDown: Text;
                        VICDrillDownUtilities: Codeunit VICDrillDownUtilities;
                    begin
                        DrillDown := VICDrillDownUtilities.GetDrillDownHyperlink(Rec.QuantityType, Rec.FacilityId, Rec.DocumentNumber);
                        if Format(DrillDown) <> '' then
                            Hyperlink((DrillDown));
                    end;
                }
                field("Source"; Rec.QuantityType)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = true;
                    ToolTip = 'Specifies the batch source of the line or a firm/unfirmed planned order.';
                }
                field("Quantity"; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the remaining quantity.';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then begin end;
    end;

    var
        Item: Record Item;
        Location: Record Location;
        LocationCode: Code[10];
        LocationFilter: Text;
        CalcVicinityATPPageDate: Codeunit "VICATPManagement";
        ItemNo: Code[20];
        IncludePlannedOrders: Boolean;
        Emphasize: Boolean;
        EnableShowDocumentAction: Boolean;

    local procedure ATPPageCaption(): Text[250]
    begin
        exit(StrSubstNo('%1 %2', Item."No.", Item.Description));
    end;

    procedure SetItem(var NewItem: Record Item)
    begin
        Item.Copy(NewItem);
        UpdateItemRequestFields(Item);
    end;

    procedure SetPlanningItemDetails(PlanningItemDetails: JsonArray)
    var
        PlanningItemQuantitiesDetail: JsonToken;
        EntryNumber: Integer;
        VICJsonUtilities: Codeunit VICJSONUtilities;
    begin
        EntryNumber := 0;
        foreach PlanningItemQuantitiesDetail in PlanningItemDetails do begin
            Rec.Init();
            Rec."Entry No." := EntryNumber;
            EntryNumber := EntryNumber + 1;
            Rec."No." := Item."No.";
            Rec.TransactionDate := DT2Date(VICJsonUtilities.GetDateFromJson(PlanningItemQuantitiesDetail, 'TransactionDate'));
            Rec.FacilityId := VICJsonUtilities.GetTextFromJson(PlanningItemQuantitiesDetail, 'FacilityId');
            Rec.DocumentNumber := VICJsonUtilities.GetTextFromJson(PlanningItemQuantitiesDetail, 'DocumentNumber');
            Rec.QuantityType := PlanningItemQuantityType.FromInteger(VICJsonUtilities.GetIntegerFromJson(PlanningItemQuantitiesDetail, 'PlanningItemType'));
            if (Rec.QuantityType = PlanningItemQuantityType::BatchEndItemBOM) or (Rec.QuantityType = PlanningItemQuantityType::BatchIngredient) then
                Rec.Quantity := -VICJsonUtilities.GetDecimalFromJson(PlanningItemQuantitiesDetail, 'Quantity')
            else
                Rec.Quantity := VICJsonUtilities.GetDecimalFromJson(PlanningItemQuantitiesDetail, 'Quantity');
            Rec.Insert();
        end;
    end;

    local procedure UpdateItemRequestFields(var Item: Record Item)
    begin
        ItemNo := Item."No.";
        // LocationFilter := '';
        // if Item.GetFilter("Location Filter") <> '' then
        //     LocationFilter := Item.GetFilter("Location Filter");
        // VariantFilter := '';
        // if Item.GetFilter("Variant Filter") <> '' then
        //     VariantFilter := Item.GetFilter("Variant Filter");
    end;

    // // local procedure ItemIsSet(): Boolean
    // // begin
    // //     exit(Item."No." <> '');
    // // end;

    protected procedure ValidateItemNo()
    var
        ProductionScheduleManagement: Codeunit VICProdScheduleManagement;
        PlanningItemQuantities: JsonObject;
        PlanningItemQuantitiesDetails: JsonToken;
    begin
        if ItemNo <> Item."No." then begin
            Item.Get(ItemNo);
            OnValidateItemNo(Item);
            Rec.DeleteAll();
            PlanningItemQuantities := ProductionScheduleManagement.FetchPlanningItemQuantitiesFromWebApi(Item."No.");
            if not PlanningItemQuantities.AsToken().SelectToken('[' + '''' + 'PlanningItemQuantityDetails' + '''' + ']', PlanningItemQuantitiesDetails) then
                exit;
            SetPlanningItemDetails(PlanningItemQuantitiesDetails.AsArray());
            CurrPage.Update(false);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateItemNo(var Item: Record Item)
    begin
    end;
}


