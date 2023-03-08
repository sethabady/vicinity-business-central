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
        JsonToken: JsonToken;
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

            // Message('%1 EndItems: %2', Url, ResponseString);

            JsonToken.ReadFrom(ResponseString);
            JToken.ReadFrom(ResponseString);
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
                            if (IncludePlannedOrders) then begin
                                InvtPageData.Init();
                                InvtPageData.Code := '';
                                InvtPageData."Line No." := LineNo;
                                LineNo := LineNo + 1;
                                InvtPageData."Period Type" := Date."Period Type";
                                InvtPageData.Description := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Description').AsValue().AsText();
                                ScheduledReceipt := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'Quantity').AsValue().AsDecimal();
                                OpeningBalance := OpeningBalance + ScheduledReceipt;
                                InvtPageData."Projected Inventory" := OpeningBalance;
                                DateFromRecord := GetJsonToken(PlanningTransactionDetailToken.AsObject(), 'TransactionDate').AsValue.AsText();

                                // Date is expected to be YYYY-MM-DD so we need to remove the time portion.
                                DateParts := DateFromRecord.Split('T');
                                Evaluate(InvtPageData."Period Start", DateParts.Get(1));
                                Evaluate(InvtPageData.Code, DateParts.Get(1));
                                InvtPageData."Scheduled Receipt" := ScheduledReceipt;
                                InvtPageData.Source := GetEntityTypeDescription(EntityType);
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
                            InvtPageData.Source := GetEntityTypeDescription(EntityType);
                            InvtPageData.Level := 1;
                            InvtPageData.Insert();
                        end;
                end;
            end;
        end
        else
            Message('Web service call failed.');
    end;

    /* 
            enum TransactionEntityType : byte
            {
                OpeningBalance = 0,
                Ingredient = 1,
                ByCoProduct = 2,
                BOM = 3,
                EndItem = 4,
                PlannedOrder = 5,
                POReceipt = 6,
                SOShipment = 7
            }
     */

    local procedure GetEntityTypeDescription(EntityType: integer): Text
    var
        Description: Text;
    begin
        Description := 'Unknown';
        case EntityType of
            0:
                Description := '';
            1:
                Description := 'Batch Ingredient';
            2:
                Description := 'Batch By/Co Product';
            3:
                Description := 'Batch Bill of Material';
            4:
                Description := 'Batch End Item';
            5:
                Description := 'Firm Planned Order';
            6:
                Description := 'Purchase Order';
            7:
                Description := 'Sales Order';
        end;
        Exit(Description);
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