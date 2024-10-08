codeunit 50180 VICWebApiInterface
{
    [IntegrationEvent(false, false)]
    procedure OnFetchBatchSummaries()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFetchBatchEndItems(FacilityId: Text; BatchNumber: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostBatchEndItems(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    begin
    end;

    local procedure InitBatches()
    var
        VICBatch: Record VICBatch;
        VICBatchEndItem: Record VICBatchEndItem;
    begin
        VICBatch.Reset();
        VICBatch.DeleteAll();
        VICBatch.SetCurrentKey(FacilityId, BatchNumber);
        VICBatchEndItem.Reset();
        VICBatchEndItem.DeleteAll();
        VICBatchEndItem.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::VICWebApiInterface, 'OnFetchBatchSummaries', '', false, false)]
    local procedure OnFetchBatchSummariesSubscriber()
    var
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
        VICBatch: Record VICBatch;
        VICBatchEndItem: Record VICBatchEndItem;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseString: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenBatch: JsonToken;
    begin
        InitBatches();
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;

        Url := StrSubstNo('%1/vicinityservice/batch/%2/%3/list', VicinityApiUrl, VicinityCompanyId, '');
        Url := StrSubstNo('%1/batch/%2/list', VicinityApiUrl, VicinityCompanyId);
        Request.Method := 'GET';
        Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchSummariesSubscriber Client.Send error:\\' + GetLastErrorText);
        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        foreach JsonTokenBatch in JsonTokenResponseString.AsArray()
        do begin
            VICBatch.Init();
            VICBatch.FacilityId := GetJsonToken(JsonTokenBatch.AsObject(), 'FacilityId').AsValue().AsText();
            VICBatch.BatchNumber := GetJsonToken(JsonTokenBatch.AsObject(), 'BatchNumber').AsValue().AsText();
            VICBatch.BatchDescription := GetJsonToken(JsonTokenBatch.AsObject(), 'Description').AsValue().AsText();
            SetDateFromJson(JsonTokenBatch, 'PlanStartDate', VICBatch.PlanStartDate);
            SetDateFromJson(JsonTokenBatch, 'PlanEndDate', VICBatch.PlanEndDate);
            SetDateFromJson(JsonTokenBatch, 'ActualStartDate', VICBatch.ActualStartDate);
            SetDateFromJson(JsonTokenBatch, 'ActualEndDate', VICBatch.ActualEndDate);
            VICBatch.ProcessingStage := BatchProcessingStage::Released;
            VICBatch.Status := BatchStatus::Active;
            VICBatch.PostThruToBC := true;
            VICBatch.Barcode := '%P%' + VICBatch.BatchNumber + '|||' + VICBatch.FacilityId + ' 00001';
            VICBatch.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::VICWebApiInterface, 'OnFetchBatchEndItems', '', false, false)]
    local procedure OnFetchBatchEndItemsSubscriber(FacilityId: Text; BatchNumber: Text)
    var
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
        VICBatch: Record VICBatch;
        VICBatchEndItem: Record VICBatchEndItem;
        Item: Record Item;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseString: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenBatchEndItem: JsonToken;
        JsonTokenBatchEndItems: JsonToken;
        JsonArrayBatchEndItems: JsonArray;

    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        VICBatchEndItem.Reset();
        VICBatchEndItem.DeleteAll();
        VICBatchEndItem.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);


        // VicinityCompanyId := 'SA_BC';
        // VicinityApiUrl := 'http://localhost:8085/VicinityWebPublic/api/vicinityservice';
        //        Url := VicinityApiUrl + '/planning/planningtransactions?companyId=' + VicinityCompanyId + '&userId=SABADY&componentId=' + ItemNo + ' &locationId=' + LocationCode + '&includeErpData=true';

        Url := StrSubstNo('%1/batch/%2/%3/%4', VicinityApiUrl, VicinityCompanyId, FacilityId, BatchNumber);


        // RequestObject.Add('companyId', 'SA_BC');
        // RequestObject.Add('facilityId', 'CHICAGO');
        // RequestObject.WriteTo(JsonRequestData);
        // Content.WriteFrom(JsonRequestData);

        // Content.GetHeaders(Headers);
        // Headers.Clear();
        // Headers.Add('Content-Type', 'application/json');
        Request.Method := 'GET';
        Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
        // Request.Content := Content;
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchEndItemsSubscriber Client.Send error:\\' + GetLastErrorText);

        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        if not JsonTokenResponseString.SelectToken('[' + '''' + 'VicinityBatchEndItems' + '''' + ']', JsonTokenBatchEndItems) then
            Error('OnFetchBatchEndItemsSubscriber:\\ SelectToken VicinityBatchEndItems failed');

        JsonArrayBatchEndItems := JsonTokenBatchEndItems.AsArray();
        foreach JsonTokenBatchEndItem in JsonArrayBatchEndItems
        do begin
            VICBatchEndItem.Init();
            VICBatchEndItem.FacilityId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
            VICBatchEndItem.BatchNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
            VICBatchEndItem.ComponentId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText();
            VICBatchEndItem.LocationCode := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'SiteId').AsValue().AsText();
            VICBatchEndItem.LineIdNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();
            VICBatchEndItem.QuantityOrdered := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyCurrentInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityRemaining := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyCompleteInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityUnposted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyToCompleteInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.UnitOfMeasure := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
            VICBatchEndItem.LotNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
            if Item.Get(VICBatchEndItem.ComponentId) then
                VICBatchEndItem.Description := Item.Description
            else
                VICBatchEndItem.Description := 'NOT FOUND';
            VICBatchEndItem.BinCode := '01';
            VICBatchEndItem.Insert();
            // VICBatch.Init();
            // VICBatch.FacilityId := GetJsonToken(JsonTokenBatch.AsObject(), 'FacilityId').AsValue().AsText();
            // VICBatch.BatchNumber := GetJsonToken(JsonTokenBatch.AsObject(), 'BatchNumber').AsValue().AsText();
            // VICBatch.BatchDescripton := GetJsonToken(JsonTokenBatch.AsObject(), 'Description').AsValue().AsText();
            // SetDateFromJson(JsonTokenBatch, 'PlanStartDate', VICBatch.PlanStartDate);
            // SetDateFromJson(JsonTokenBatch, 'PlanEndDate', VICBatch.PlanEndDate);
            // SetDateFromJson(JsonTokenBatch, 'ActualStartDate', VICBatch.ActualStartDate);
            // SetDateFromJson(JsonTokenBatch, 'ActualEndDate', VICBatch.ActualEndDate);
            // VICBatch.ProcessingStage := BatchProcessingStage::Released;
            // VICBatch.Status := BatchStatus::Active;
            // VICBatch.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::VICWebApiInterface, 'OnPostBatchEndItems', '', false, false)]
    local procedure OnPostBatchEndItemsSubscriber(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JsonRequestData: Text;
        Headers: HttpHeaders;
        ResponseString: Text;
        JsonObjectResponseString: JsonObject;
        StatusMessage: Text;
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
    begin
        IsHandled := true;
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        Request.Method := 'POST';
        Url := StrSubstNo('%1/batch/posttransaction?companyId=%2', VicinityApiUrl, VicinityCompanyId);
        Request.SetRequestUri(Url);
        VicinityBatchToPost.WriteTo(JsonRequestData);
        Content.WriteFrom(JsonRequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then begin
            ResultMessage := 'OnPostBatchEndItemsSubscriber Client.Send error:\\' + GetLastErrorText + '\\';
            IsHandled := false;
            exit;
        end;

        Response.Content.ReadAs(ResponseString);
        JsonObjectResponseString.ReadFrom(ResponseString);
        StatusMessage := GetJsonToken(JsonObjectResponseString, 'StatusMessage').AsValue().AsText();
        if StatusMessage <> '' then begin
            ResultMessage := 'PostTransaction web service error: ' + StatusMessage + '\\';
            IsHandled := false;
            exit;
        end;
    end;


    // procedure InitAndFetchBatchList()
    // var
    //     Url: Text;
    //     VicinityApiUrl: Text;
    //     VicinityCompanyId: Text;
    //     VicinityUserId: Text;
    //     VicinityApiAccessKey: Text;
    //     VicinitySetup: Record "Vicinity Setup";
    //     VICBatch: Record VICBatch;

    //     Client: HttpClient;
    //     Request: HttpRequestMessage;
    //     Response: HttpResponseMessage;
    //     ResponseString: Text;
    //     JsonTokenResponseString: JsonToken;
    //     JsonTokenBatch: JsonToken;
    // begin
    //     VICBatch.Reset();
    //     VICBatch.DeleteAll();
    //     VICBatch.SetCurrentKey(FacilityId, BatchNumber);



    //     if not VicinitySetup.Get() then begin
    //         Error('Vicinity Setup record does not exist')
    //     end;

    //     VicinityApiUrl := VicinitySetup.ApiUrl;
    //     VicinityCompanyId := VicinitySetup.CompanyId;
    //     VicinityUserId := VicinitySetup.ApiUserName;
    //     if (StrLen(VicinityUserId) = 0) then begin
    //         VicinityUserId := UserId;
    //     end;


    //     VicinityCompanyId := 'SA_BC';
    //     VicinityApiUrl := 'http://localhost:8085/VicinityWebPublic/api/vicinityservice';
    //     //        Url := VicinityApiUrl + '/planning/planningtransactions?companyId=' + VicinityCompanyId + '&userId=SABADY&componentId=' + ItemNo + ' &locationId=' + LocationCode + '&includeErpData=true';

    //     Url := StrSubstNo('%1/batch/%2/%3/list', VicinityApiUrl, VicinityCompanyId, 'CHICAGO');


    //     // RequestObject.Add('companyId', 'SA_BC');
    //     // RequestObject.Add('facilityId', 'CHICAGO');
    //     // RequestObject.WriteTo(JsonRequestData);
    //     // Content.WriteFrom(JsonRequestData);

    //     // Content.GetHeaders(Headers);
    //     // Headers.Clear();
    //     // Headers.Add('Content-Type', 'application/json');
    //     Request.Method := 'GET';
    //     Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
    //     // Request.Content := Content;
    //     if not Client.Send(Request, Response) then
    //         Error('Unable to retrieve batches.');

    //     Response.Content.ReadAs(ResponseString);
    //     JsonTokenResponseString.ReadFrom(ResponseString);
    //     foreach JsonTokenBatch in JsonTokenResponseString.AsArray()
    //     do begin
    //         VICBatch.Init();
    //         VICBatch.FacilityId := GetJsonToken(JsonTokenBatch.AsObject(), 'FacilityId').AsValue().AsText();
    //         VICBatch.BatchNumber := GetJsonToken(JsonTokenBatch.AsObject(), 'BatchNumber').AsValue().AsText();
    //         VICBatch.BatchDescripton := GetJsonToken(JsonTokenBatch.AsObject(), 'Description').AsValue().AsText();
    //         SetDateFromJson(JsonTokenBatch, 'PlanStartDate', VICBatch.PlanStartDate);
    //         SetDateFromJson(JsonTokenBatch, 'PlanEndDate', VICBatch.PlanEndDate);
    //         SetDateFromJson(JsonTokenBatch, 'ActualStartDate', VICBatch.ActualStartDate);
    //         SetDateFromJson(JsonTokenBatch, 'ActualEndDate', VICBatch.ActualEndDate);
    //         VICBatch.ProcessingStage := BatchProcessingStage::Released;
    //         VICBatch.Status := BatchStatus::Active;
    //         VICBatch.Insert();
    //     end;
    // end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

    local procedure SetDateFromJson(JsonToken: JsonToken; TokenKey: Text; var DateToSet: Date)
    var
        JsonTokenDate: JsonToken;
        DateFromRecord: Text;
        DateParts: List of [Text];
    begin
        JsonTokenDate := GetJsonToken(JsonToken.AsObject(), TokenKey);
        if not JsonTokenDate.AsValue().IsNull() then begin
            DateFromRecord := GetJsonToken(JsonToken.AsObject(), TokenKey).AsValue.AsText();
            DateParts := DateFromRecord.Split('T');
            Evaluate(DateToSet, DateParts.Get(1));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure MyOnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        if CaptionArea = '10' then begin
            Caption := 'GOOMBAH HELLO'; //GetCaption(CaptionExpr);
            Resolved := true;
        end;
    end;
}