codeunit 50146 "VICATPManagement"
{
    local procedure ShowVicinityATP(ItemNo: Code[20]; LocationCode: Code[20]; var InvtPageData: Record "Inventory Page Data"; IncludePlannedOrders: Boolean)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Url: Text;
        ResponseString: Text;
        InventoryPageData: Record "Inventory Page Data" temporary;
        LineNo: Integer;
        Date: Record Date;

        JToken: JsonToken;
        JArray: JsonArray;
        JsonObject: JsonObject;
//        JsonToken: JsonToken;
        PlanningTransactionDetailToken: JsonToken;
        VicinitySetup: Record "Vicinity Setup";

        ComponentDescription: Text;
        PlanningTransactionDetails: JsonToken;
        OpeningBalance: Decimal;
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        RecordType: Integer;
        EntityType: Integer;
        DateFromRecord: Text;
        DateParts: List of [Text];

        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
    begin
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist')
        end;

        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;

        // https://vwswampdev.cloud.vicinitybrew.com/api/vicinityservice/planning/planningtransactions?companyId=SwampDevBC&userId=SABADY&componentId=DC-FG01&locationId=WAREHOUSE&includeErpData=true

        InvtPageData.Reset();
        InvtPageData.DeleteAll();
        InvtPageData.SetCurrentKey("Period Start", "Line No.");

        OpeningBalance := 0;
        LineNo := 1;

        //        VicinityCompanyId := 'SwampDevBC';
        //        VicinityApiUrl := 'https://vwswampdev.cloud.vicinitybrew.com/api/vicinityservice';
        //        Url := VicinityApiUrl + '/planning/planningtransactions?companyId=' + VicinityCompanyId + '&userId=SABADY&componentId=' + ItemNo + ' &locationId=' + LocationCode + '&includeErpData=true';

        Url := StrSubstNo('%1/planning/planningtransactions?companyId=%2&userId=%3&componentId=%4&locationId=%5&includeErpData=true', VicinityApiUrl, VicinityCompanyId, VicinityUserId, ItemNo, LocationCode);

        if Client.Get(Url, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseString);
            
            // if not JsonToken.ReadFrom(ResponseString) then
            //     Error('Invalid JSON from Vicinity ATP service.');

            if not JToken.ReadFrom(ResponseString) then
                Error('Reading JSON from Vicinity ATP service failed.');

            if not JToken.SelectToken('[' + '''' + 'PlanningTransactionDetails' + '''' + ']', PlanningTransactionDetails) then
                Error('SelectToken PlanningTransactionDetails failed');
            JArray := PlanningTransactionDetails.AsArray();
            foreach PlanningTransactionDetailToken in JArray
            do begin
                RecordType := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'RecordType').AsValue().AsInteger();
                EntityType := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'EntityType').AsValue().AsInteger();
                case RecordType of
                    0:
                        begin
                            InvtPageData.Init();
                            InvtPageData.Code := '';
                            InvtPageData."Line No." := LineNo;
                            LineNo := LineNo + 1;
                            InvtPageData."Period Type" := Date."Period Type";
                            InvtPageData.Description := 'Opening Balance';
                            OpeningBalance := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Quantity').AsValue().AsDecimal();
                            InvtPageData."Projected Inventory" := OpeningBalance;
                            InvtPageData.Level := 0;
                            InvtPageData.Insert();
                        end;
                    2, 3, 4:
                        begin
                            // By/Co Product, End-Item, Firm Planned Order
                            if (IncludePlannedOrders or (EntityType <> 5)) then begin
                                InvtPageData.Init();
                                InvtPageData.Code := '';
                                InvtPageData."Line No." := LineNo;
                                LineNo := LineNo + 1;
                                InvtPageData."Period Type" := Date."Period Type";
                                InvtPageData.Description := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Description').AsValue().AsText();
                                ScheduledReceipt := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Quantity').AsValue().AsDecimal();
                                InvtPageData."Document No." := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Document').AsValue().AsText();
                                InvtPageData.FacilityId := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'FacilityId').AsValue().AsText();
                                InvtPageData.VicinityEntityType := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'EntityType').AsValue().AsInteger();
                                OpeningBalance := OpeningBalance + ScheduledReceipt;
                                InvtPageData."Projected Inventory" := OpeningBalance;
                                DateFromRecord := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'TransactionDate').AsValue.AsText();

                                // Date is expected to be YYYY-MM-DD so we need to remove the time portion.
                                DateParts := DateFromRecord.Split('T');
                                Evaluate(InvtPageData."Period Start", DateParts.Get(1));
                                Evaluate(InvtPageData.Code, DateParts.Get(1));
                                InvtPageData."Scheduled Receipt" := ScheduledReceipt;
                                InvtPageData.Source := GetEntityTypeDescription(TransactionEntityType.FromInteger(EntityType));
                                InvtPageData.Level := 1;
                                InvtPageData.Insert();
                            end;
                        end;
                    1, 5:
                        begin
                            // Ingredient, BOM, Shipment
                            InvtPageData.Init();
                            InvtPageData.Code := '';
                            InvtPageData."Line No." := LineNo;
                            LineNo := LineNo + 1;
                            InvtPageData."Period Type" := Date."Period Type";
                            InvtPageData.Description := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Description').AsValue().AsText();
                            GrossRequirement := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Quantity').AsValue().AsDecimal();
                            OpeningBalance := OpeningBalance - GrossRequirement;
                            InvtPageData."Projected Inventory" := OpeningBalance;
                            DateFromRecord := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'TransactionDate').AsValue.AsText();
                            DateParts := DateFromRecord.Split('T');
                            Evaluate(InvtPageData."Period Start", DateParts.Get(1));
                            Evaluate(InvtPageData.Code, DateParts.Get(1));
                            InvtPageData."Gross Requirement" := GrossRequirement;
                            InvtPageData.Source := GetEntityTypeDescription(TransactionEntityType.FromInteger(EntityType));
                            InvtPageData."Document No." := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Document').AsValue().AsText();
                            InvtPageData.FacilityId := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'FacilityId').AsValue().AsText();
                            InvtPageData.VicinityEntityType := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'EntityType').AsValue().AsInteger();
                            InvtPageData.Level := 1;
                            InvtPageData.Insert();
                        end;
                end;
            end;
        end
        else
            Message('Web service call failed.');
    end;

    local procedure GetEntityTypeDescription(EntityType: enum TransactionEntityType): Text
    var
        Description: Text;
        TransactionEntityType: enum TransactionEntityType;
    begin
        Description := 'Unknown';
        case EntityType of
            TransactionEntityType::OpeningBalance:
                Description := '';
            TransactionEntityType::Ingredient:
                Description := 'Batch Ingredient';
            TransactionEntityType::ByCoProduct:
                Description := 'Batch By/Co Product';
            TransactionEntityType::BillOfMaterial:
                Description := 'Batch Bill of Material';
            TransactionEntityType::EndItem:
                Description := 'Batch End Item';
            TransactionEntityType::PlannedOrder:
                Description := 'Firm Planned Order';
            TransactionEntityType::POReceipt:
                Description := 'Purchase Order';
            TransactionEntityType::SOShipment:
                Description := 'Sales Order';
        end;
        Exit(Description);
    end;

    procedure GetDrillback(InvtPageData: Record "Inventory Page Data"): Text
    var
        Drillback: Text;
        TransactionEntityType: enum TransactionEntityType;
        DrillbackId: Integer;
        VicinityDrillback: Record VICDrillback;
    begin
        DrillbackId := -1;
        case Enum::TransactionEntityType.FromInteger(InvtPageData.VicinityEntityType) of
            TransactionEntityType::Ingredient, TransactionEntityType::ByCoProduct, TransactionEntityType::BillOfMaterial, TransactionEntityType::EndItem:
                DrillbackId := 1;
            TransactionEntityType::PlannedOrder:
                DrillbackId := 9;
        end;
        if DrillbackId <> -1 then begin
            VicinityDrillback.SetCurrentKey("Drillback ID");
            VicinityDrillback.SetRange("Drillback ID", DrillbackId);
            if VicinityDrillback.Find('-') then begin
                Drillback := VicinityDrillback."Drillback Hyperlink";
                case Enum::TransactionEntityType.FromInteger(InvtPageData.VicinityEntityType) of
                    TransactionEntityType::Ingredient, TransactionEntityType::ByCoProduct, TransactionEntityType::BillOfMaterial, TransactionEntityType::EndItem:
                        Drillback := Drillback + '&FacilityID=' + InvtPageData.FacilityId + '&BatchNumber=' + InvtPageData."Document No.";
                    TransactionEntityType::PlannedOrder:
                        Drillback := Drillback + '&FacilityID=' + InvtPageData.FacilityId + '&PlannedOrderNumber=' + InvtPageData."Document No.";
                end
            end
        end;
        Exit(Drillback);
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

    // Called by Vicinity ATP Page.
    procedure CreateVicinityATP(var ItemNo: Code[20]; var Location: Code[10]; var InvtPageData: Record "Inventory Page Data"; IncludePlannedOrders: Boolean)
    begin
        ShowVicinityATP(ItemNo, Location, InvtPageData, IncludePlannedOrders);
    end;

    // Called by Vicinity Sales Order page extension.
    procedure ShowATPPage(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        Location: Record Location;
        ATPForm: Page "VICAvailableToPromise";
    begin
        SalesLine.TestField(SalesLine.Type, SalesLine.Type::Item);
        SalesLine.TestField(SalesLine."No.");
        SalesLine.TestField(SalesLine."Location Code");
        Item.Reset();
        Item.Get(SalesLine."No.");
        ATPForm.SetItem(Item);
        Location.Reset();
        Location.Get(SalesLine."Location Code");
        ATPForm.SetLocation(Location);
        ATPForm.LookupMode := true;
        if ATPForm.RunModal = ACTION::LookupOK then begin end;
    end;
}