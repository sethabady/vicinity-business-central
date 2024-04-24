codeunit 50410 VICProdScheduleManagement
{
    trigger OnRun()
    begin

    end;

    var
        VICJSONUtilities: Codeunit VICJSONUtilities;

    procedure LoadFormulas(Tokens: JsonToken; var TempVICFormula: Record VICFormula temporary; var UniqueIdCounter: Integer)
    var
        ResourceToken: JsonToken;
        ResultToken: JsonToken;
        ErrorMessage: Text;
    begin
        if not Tokens.SelectToken('[' + '''' + 'Formulas' + '''' + ']', ResultToken) then begin
            ErrorMessage := VICJSONUtilities.GetJsonToken(Tokens.AsObject(), 'ExceptionMessage').AsValue().AsText();
            Error(ErrorMessage);
        end;
        foreach ResourceToken in ResultToken.AsArray()
        do begin
            TempVICFormula.Init();
            TempVICFormula.FormulaId := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ResourceId').AsValue().AsText();
            TempVICFormula.Description := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'Description').AsValue().AsText();
            TempVICFormula.Insert();
        end;
    end;

    procedure LoadComponents(Tokens: JsonToken; var TempVICComponent: Record VICComponent temporary; var UniqueIdCounter: Integer)
    var
        ResourceToken: JsonToken;
        ResultToken: JsonToken;
        ErrorMessage: Text;
    begin
        if not Tokens.SelectToken('[' + '''' + 'Components' + '''' + ']', ResultToken) then begin
            ErrorMessage := VICJSONUtilities.GetJsonToken(Tokens.AsObject(), 'ExceptionMessage').AsValue().AsText();
            Error(ErrorMessage);
        end;
        foreach ResourceToken in ResultToken.AsArray()
        do begin
            TempVICComponent.Init();
            TempVICComponent.ComponentId := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ResourceId').AsValue().AsText();
            TempVICComponent.Description := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'Description').AsValue().AsText();
            TempVICComponent.Insert();
        end;
    end;

    // Load all resources of type ResourceType from json retrieved from Vicinity API.
    procedure LoadResources(Tokens: JsonToken; ResourceId: Text[30]; ResourceType: Enum VICScheduleGroupBy; AddBlank: Boolean; var TempVICResource: Record VICResource temporary; var UniqueIdCounter: Integer)
    var
        ResourceToken: JsonToken;
        ResultToken: JsonToken;
        ErrorMessage: Text;
    begin
        if AddBlank then begin
            TempVICResource.Init();
            TempVICResource.ResourceId := '';
            // UniqueIdCounter := UniqueIdCounter + 1;
            TempVICResource.ScheduleObjectId := 'Activity_' + Format(ResourceType) + '_'; // + Format(UniqueIdCounter);
            TempVICResource.Description := 'Unassigned';
            TempVICResource.ResourceType := ResourceType;
            TempVICResource.Insert();
        end;
        if ResourceType = VICScheduleGroupBy::PlanningAttribute then begin
            if not Tokens.SelectToken('[' + '''' + ResourceId + '''' + ']', ResultToken) then begin
                ErrorMessage := 'The resource: ' + ResourceId + ' was not found in the data retrieved from Vicinity API.';
                Error(ErrorMessage);
            end
        end
        else
            if not Tokens.SelectToken('[' + '''' + ResourceId + '''' + ']', ResultToken) then begin
                ErrorMessage := 'The resource: ' + ResourceId + ' was not found in the data retrieved from Vicinity API.';
                Error(ErrorMessage);
            end;
        foreach ResourceToken in ResultToken.AsArray()
        do begin
            TempVICResource.Init();
            if ResourceType = VICScheduleGroupBy::PlanningAttribute then begin
                TempVICResource.ResourceId := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ValueSetName').AsValue().AsText();
                TempVICResource.Description := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ValueSetId').AsValue().AsText() + '_' + Format(VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ValueSetValue').AsValue().AsInteger());
            end
            else begin
                TempVICResource.ResourceId := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'ResourceId').AsValue().AsText();
                TempVICResource.Description := VICJSONUtilities.GetJsonToken(ResourceToken.AsObject(), 'Description').AsValue().AsText();
            end;

            // UniqueIdCounter := UniqueIdCounter + 1;
            TempVICResource.ScheduleObjectId := 'Activity_' + Format(ResourceType) + '_'; // + Format(UniqueIdCounter);
            TempVICResource.ResourceType := ResourceType;
            TempVICResource.Insert();
        end;
    end;

    procedure LoadProductionSchedule(Tokens: JsonToken; var TempVICProductionSchedule: Record VICProductionSchedule temporary; var UniqueIdCounter: Integer; StartDate: Date)
    var
        ResultToken: JsonToken;
        ResultTokenArray: JsonArray;
        ProductionScheduleToken: JsonToken;
        ErrorMessage: Text;
        StartDateFromRecord: Date;
    begin
        if not Tokens.SelectToken('[' + '''' + 'PlanningScheduleDetails' + '''' + ']', ResultToken) then begin
            ErrorMessage := VICJSONUtilities.GetJsonToken(Tokens.AsObject(), 'ExceptionMessage').AsValue().AsText();
            Error(ErrorMessage);
        end;
        UniqueIdCounter := 0;
        ResultTokenArray := ResultToken.AsArray();
        foreach ProductionScheduleToken in ResultToken.AsArray()
        do begin
            TempVICProductionSchedule.Init();
            UniqueIdCounter := UniqueIdCounter + 1;
            TempVICProductionSchedule.ScheduleObjectId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'BatchOrPlannedOrderNumber') + Format(UniqueIdCounter);
            TempVICProductionSchedule.ComponentId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'ComponentId');
            TempVICProductionSchedule.ComponentDescription := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'ComponentDescription');
            TempVICProductionSchedule.FormulaId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'FormulaId');
            TempVICProductionSchedule.FormulaDescription := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'FormulaDescription');
            TempVICProductionSchedule.FacilityId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'FacilityId');
            TempVICProductionSchedule.StartDateTime := VICJSONUtilities.GetDateFromJson(ProductionScheduleToken, 'StartDateUtc');
            TempVICProductionSchedule.EndDateTime := VICJSONUtilities.GetDateFromJson(ProductionScheduleToken, 'FinishDateUtc');

            if TempVICProductionSchedule.EndDateTime = TempVICProductionSchedule.StartDateTime then
                TempVICProductionSchedule.EndDateTime := System.CreateDateTime(System.CalcDate('+3D', System.DT2Date(TempVICProductionSchedule.StartDateTime)), 235959T);

            if (VICJSONUtilities.GetBooleanFromJson(ProductionScheduleToken, 'IsABatch')) then begin
                TempVICProductionSchedule.RecordType := VICVisualObjectType::BatchActivity;
                TempVICProductionSchedule.IsABatch := true
            end
            else begin
                TempVICProductionSchedule.RecordType := VICVisualObjectType::PlannedOrderActivity;
                TempVICProductionSchedule.IsABatch := false
            end;
            TempVICProductionSchedule.OrderNumber := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'BatchOrPlannedOrderNumber');
            TempVICProductionSchedule.ProcessCellId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'ProcessCellId');
            TempVICProductionSchedule.FillUnitId := VICJSONUtilities.GetTextFromJson(ProductionScheduleToken, 'FillUnitId');
            if (StartDate = 0D) or (TempVICProductionSchedule.StartDateTime >= CreateDateTime(StartDate, 0T)) then
                TempVICProductionSchedule.Insert();
        end;
    end;

    procedure FetchVicinityScheduleFromWebApi(var TempVICResource: Record VICResource temporary; var TempVICProductionSchedule: Record VICProductionSchedule; var TempVICFormula: Record VICFormula; var TempVICComponent: Record VICComponent; StartDate: Date; EndDate: Date; var UniqueIdCounter: Integer; Batches: Boolean; FirmPlannedOrders: Boolean; UnfirmedPlannedOrders: Boolean) //; var ManufacturingOrders: JsonArray; var Formulas: JsonArray; var Components: JsonArray)
    var
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";

        // VICFacility: Record VICFacility temporary;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseString: Text;
        RequestObject: JsonObject;
        JsonRequestObject: JsonObject;
        JsonRequestData: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenManufacturingOrders: JsonToken;
        JsonTokenFormulas: JsonToken;
        JsonTokenComponents: JsonToken;
        JsonTokenErrorMessage: JsonToken;


        FacilitiesToken: JsonToken;
        FacilityJsonToken: JsonToken;
        Facilities: JsonArray;

    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        Request.Method := 'POST';
        Request.SetRequestUri(StrSubstNo('%1/planning/planningschedule', VicinityApiUrl, VicinityCompanyId));
        Clear(RequestObject);
        Clear(JsonRequestObject);
        RequestObject.Add('VicinityCompanyId', VicinityCompanyId);
        if StartDate <> 0D then
            RequestObject.Add('StartDate', GetDateForWebApiCall(StartDate - 2))
        else
            RequestObject.Add('StartDate', GetDateForWebApiCall(Today - 90)); // StartDate));
        if EndDate <> 0D then
            RequestObject.Add('EndDate', GetDateForWebApiCall(EndDate + 2))
        else
            RequestObject.Add('EndDate', GetDateForWebApiCall(EndDate));
        RequestObject.Add('IncludeBatches', Batches);
        RequestObject.Add('IncludeFirmPlannedOrders', FirmPlannedOrders);
        RequestObject.Add('IncludeUnfirmPlannedOrders', UnfirmedPlannedOrders);
        RequestObject.WriteTo(JsonRequestData);
        Content.WriteFrom(JsonRequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then
            Error('Unable to retrieve planning schedule.');
        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);

        TempVICResource.Reset();
        TempVICResource.DeleteAll();
        TempVICFormula.Reset();
        TempVICComponent.Reset();
        TempVICProductionSchedule.Reset();
        TempVICFormula.DeleteAll();
        TempVICComponent.DeleteAll();
        TempVICProductionSchedule.DeleteAll();

        UniqueIdCounter := 0;
        LoadResources(JsonTokenResponseString, 'Facilities', VICScheduleGroupBy::Facility, false, TempVICResource, UniqueIdCounter);
        LoadResources(JsonTokenResponseString, 'ProcessCells', VICScheduleGroupBy::ProcessCell, true, TempVICResource, UniqueIdCounter);
        LoadResources(JsonTokenResponseString, 'ProcedureUnits', VICScheduleGroupBy::FillUnit, true, TempVICResource, UniqueIdCounter);
        LoadResources(JsonTokenResponseString, 'PlanningAttributeValues', VICScheduleGroupBy::PlanningAttribute, false, TempVICResource, UniqueIdCounter);

        // LoadResources(JsonTokenResponseString, 'ProcedureUnits', VICScheduleGroupBy::ProcedureUnit, true, TempVICResource);

        LoadFormulas(JsonTokenResponseString, TempVICFormula, UniqueIdCounter);
        LoadComponents(JsonTokenResponseString, TempVICComponent, UniqueIdCounter);

        // UniqueIdCounter := 0;
        LoadProductionSchedule(JsonTokenResponseString, TempVICProductionSchedule, UniqueIdCounter, StartDate);

        /* 
        curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ \ 
           "VicinityCompanyId": "SA_BC", \ 
           "StartDate": "2020-12-01", \ 
           "EndDate": "2023-07-31", \ 
           "IncludeBatches": true, \ 
           "IncludeFirmPlannedOrders": true, \ 
           "IncludeUnfirmPlannedOrders": true \ 
         }' 'http://v-dev1:8085/VicinityWebPublic/api/vicinityservice/planning/planningschedule'        
         */
    end;

    procedure PostScheduleUpdate(PlanningScheduleDetails: JsonArray)
    var
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseString: Text;
        RequestObject: JsonObject;
        RequestData: Text;
    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        
        Request.Method := 'POST';
        Request.SetRequestUri(StrSubstNo('%1/planning/updateplanningschedule', VicinityApiUrl, VicinityCompanyId));
        Clear(RequestObject);
        RequestObject.Add('VicinityCompanyId', VicinityCompanyId);
        RequestObject.Add('PlanningScheduleDetails', PlanningScheduleDetails);
        RequestObject.WriteTo(RequestData);
        Content.WriteFrom(RequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then
            Error('Unable to update planning schedule.');
        Response.Content.ReadAs(ResponseString);


    end;


    // local procedure CreateMOActivity(ProductionScheduleToken: JsonToken;  var TempVICProductionSchedule: record VICProductionSchedule temporary)
    // var
    //     // DateTimeFromRecord: DateTime;
    //     ComponentStartDateTime: DateTime;
    //     ComponentEndDateTime: DateTime;
    //     IsABatch: Boolean;
    //     TempText: Text;
    //     ProductionScheduleObject: JsonObject;
    // begin
    //     // ProductionScheduleObject := CreateJsonObject();
    //     // TempText := 'Act_ManufacturingOrder_' + GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue().AsText() + Format(UniqueIdCounter);
    //     // MOActivityJsonObject.Add('ID', TempText);
    //     // ProductionSchedule.ScheduleId := TempText;
    //     // MOActivityJsonObject.Add('ParentID', ParentId);
    //     // ProductionSchedule.ParentScheduleId := ParentId;

    //     // // Increment global ID counter.
    //     // UniqueIdCounter := UniqueIdCounter + 1;

    //     // // For development, default activity to 5 days if finish date is not greater than start date.
    //     // ComponentStartDateTime := GetJsonToken(MOJsonToken.AsObject(), 'StartDateUtc').AsValue.AsDateTime();
    //     // if System.DT2Time(ComponentStartDateTime) = 120000T then
    //     //     ComponentStartDateTime := CreateDateTime(System.DT2Date(ComponentStartDateTime), 0T);

    //     // ComponentEndDateTime := GetJsonToken(MOJsonToken.AsObject(), 'FinishDateUtc').AsValue.AsDateTime();
    //     // if System.DT2Time(ComponentEndDateTime) = 120000T then
    //     //     ComponentEndDateTime := CreateDateTime(System.DT2Date(ComponentEndDateTime), 235959T);

    //     // MOActivityJsonObject.Add('Start', ComponentStartDateTime);
    //     // MOActivityJsonObject.Add('End', ComponentEndDateTime);
    //     // MOActivityJsonObject.Add('BarShape', 3);    // rectangle

    //     // MOActivityJsonObject.Add('AllowedBarDragModes', 7);

    //     // MOActivityJsonObject.Add('TableText', GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText());

    //     // MOActivityJsonObject.Add('BarText', GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText());
    //     // IsABatch := GetJsonToken(MOJsonToken.AsObject(), 'IsABatch').AsValue.AsBoolean();
    //     // if IsABatch then begin
    //     //     ProductionSchedule.RecordType := VICVisualObjectType::BatchActivity;
    //     //     MOActivityJsonObject.Add('Color', 'blue');
    //     //     TempText := 'Batch: ' + GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText() +
    //     //     '<br>Start Date: ' + FORMAT(ComponentStartDateTime) +
    //     //     '<br>Due Date: ' + FORMAT(ComponentEndDateTime);
    //     // end
    //     // else begin
    //     //     ProductionSchedule.RecordType := VICVisualObjectType::PlannedOrderActivity;
    //     //     MOActivityJsonObject.Add('Color', '#e69500');
    //     //     TempText := 'Planned Order: ' + GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText() +
    //     //     '<br>Start Date: ' + FORMAT(ComponentStartDateTime) +
    //     //     '<br>Due Date: ' + FORMAT(ComponentEndDateTime);
    //     // end;
    //     // MOActivityJsonObject.Add('TooltipText', TempText);

    //     // ProductionSchedule.FacilityId := GetJsonToken(MOJsonToken.AsObject(), 'FacilityId').AsValue().AsText();
    //     // ProductionSchedule.OrderNumber := GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue().AsText();

    //     // // 'Order Type: ' + TempText +
    //     // //     '<br>No.: ' + GetJsonToken(MOJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText() +
    //     // //     '<br>Start Date: ' + FORMAT(ComponentStartDate) +
    //     // //     '<br>Due Date: ' + FORMAT(ComponentEndDate));

    //     // MOActivityJsonObject.Add('ContextMenuID', 'CM_Activity');
    //     // MOActivityJsonObject.Add('CollapseState', 0);
    //     // exit(MOActivityJsonObject);
    // end;




    //     procedure LoadManufacturingOrderActivities(ManufacturingOrders: JsonArray; ManufacturingOrderActivities: JsonArray; ManufacturingOrderActivityLinks: JsonArray; Formulas: JsonArray; Components: JsonArray; var ProductionSchedule: Record VICProductionSchedule)
    //     var
    //         ManufacturingOrderJsonToken: JsonToken;
    //         FormulaJsonToken: JsonToken;
    //         ComponentJsonToken: JsonToken;
    //         ManufacturingOrderActivityJsonObject: JsonObject;
    //         ManufacturingOrderActivityLinkJsonObject: JsonObject;
    //         FormulaActivityJsonObject: JsonObject;
    //         ComponentActivityJsonObject: JsonObject;
    // //        DateParts: List of [Text];
    // //        DateFromRecordText: Text;
    //         DateTimeFromRecord: DateTime;
    // //        GoombahDate: Date;
    //         ParentFormulaId: Text;
    //         ParentComponentId: Text;
    //         OrderFormulaId: Text;
    //         OrderComponentId: Text;
    //         Id: Text;
    //         Act_Formula_Id: Text;
    //         Act_Component_Id: Text;
    //         Unique_Act_MO_Number: Integer;
    //         Unique_Act_Formula_Id: Integer;
    //         Unique_Act_Component_Id: Integer;
    //         FormulaStartDateTime: DateTime;
    //         FormulaEndDateTime: DateTime;
    //         // ComponentStartDate: Date;
    //         // ComponentEndDate: Date;
    //         ComponentAdded: Boolean;
    //         FormulaAdded: Boolean;
    //         IsABatch: Boolean;
    //         TempDateTime: DateTime;
    //         ComponentStartDateTime: DateTime;
    //         ComponentEndDateTime: DateTime;
    //         TempText: Text;
    //         VisualObjectType: Enum VICVisualObjectType;
    //     begin

    //         // ProductionSchedule := VICProductionScheduleMgmt.GetProductionSchedule();
    //         UniqueIdCounter := 1;

    //         Unique_Act_MO_Number := 0;
    //         Unique_Act_Component_Id := 0;
    //         Unique_Act_Formula_Id := 0;
    //         // FormulaStartDate := 0D;
    //         // ComponentStartDate := 0D;
    //         // FormulaEndDate := 0D;
    //         // ComponentEndDate := 0D;

    //         // ManufacturingOrderActivityJsonObject.Add('ID', 'Act_ManufacturingOrder_Header');
    //         // ManufacturingOrderActivityJsonObject.Add('AddIn_TableText', 'Manufacturing Orders');
    //         // ManufacturingOrderActivities.Add(ManufacturingOrderActivityJsonObject);

    //         foreach FormulaJsonToken in Formulas
    //         do begin
    //             // Add this formula to orders hiearchy.
    //             FormulaStartDateTime := 0DT;
    //             FormulaEndDateTime := 0DT;

    //             // FormulaStartDate := 0D;
    //             // FormulaEndDate := 0D;
    //             FormulaActivityJsonObject := createJsonObject();
    //             ParentFormulaId := GetJsonToken(FormulaJsonToken.AsObject(), 'ResourceId').AsValue().AsText();
    //             Act_Formula_Id := 'Act_Formula_' + ParentFormulaId + Format(Unique_Act_Formula_Id);
    //             Unique_Act_Formula_Id := Unique_Act_Formula_Id + 1;
    //             FormulaActivityJsonObject.Add('ID', Act_Formula_Id);
    //             FormulaActivityJsonObject.Add('BarShape', 1);
    //             FormulaActivityJsonObject.Add('AddIn_TableText', 'F: ' + ParentFormulaId);
    //             FormulaActivityJsonObject.Add('Color', 'pink');//  '#e69500');
    //             FormulaActivityJsonObject.Add('BarText', ParentFormulaId);
    //             FormulaActivityJsonObject.Add('AddIn_ContextMenuID', 'CM_Activity');
    //             FormulaActivityJsonObject.Add('CollapseState', 0);
    //             VisualObjectType := VisualObjectType::SummaryActivity;
    //             FormulaActivityJsonObject.Add('CustomText1', Format(VisualObjectType));
    //             FormulaAdded := false;
    //             foreach ComponentJsonToken in Components
    //             do begin
    //                 // Add this component to orders -> formulas hiearchy.
    //                 ComponentStartDateTime := 0DT;
    //                 ComponentEndDateTime := 0DT;

    //                 // ComponentStartDate := 0D;
    //                 // ComponentEndDate := 0D;
    //                 ComponentActivityJsonObject := createJsonObject();
    //                 ParentComponentId := GetJsonToken(ComponentJsonToken.AsObject(), 'ResourceId').AsValue().AsText();
    //                 Act_Component_Id := 'Act_Component_' + ParentComponentId + Format(Unique_Act_Component_Id);
    //                 Unique_Act_Component_Id := Unique_Act_Component_Id + 1;
    //                 ComponentActivityJsonObject.Add('ID', Act_Component_Id);
    //                 ComponentActivityJsonObject.Add('ParentID', Act_Formula_Id); // Id of the formula we're processing
    //                 // ComponentActivityJsonObject.Add('Start', CreateDateTime(20210101D, 0T));
    //                 // ComponentActivityJsonObject.Add('End', CreateDateTime(20231231D, 0T));
    //                 ComponentActivityJsonObject.Add('BarShape', 1);
    //                 ComponentActivityJsonObject.Add('AddIn_TableText', 'C: ' + ParentComponentId);
    //                 ComponentActivityJsonObject.Add('Color', '#e69500');
    //                 // ManufacturingOrderActivityJsonObject.Add('AddIn_BarText', FORMAT(lrecServiceHeader."No."));
    //                 // ManufacturingOrderActivityJsonObject.Add('AddIn_TooltipText', 'Service Header' +
    //                 //   '<br>Document Type: ' + FORMAT(lrecServiceHeader."Document Type") +
    //                 //   '<br>No.: ' + FORMAT(lrecServiceHeader."No.") +
    //                 //   '<br>Due Date: ' + FORMAT(lrecServiceHeader."Due Date"));
    //                 ComponentActivityJsonObject.Add('AddIn_ContextMenuID', 'CM_Activity');
    //                 ComponentActivityJsonObject.Add('CollapseState', 0);
    //                 // ManufacturingOrderActivities.Add(ComponentActivityJsonObject);

    //                 // OrderFormulaId := GetJsonToken(ComponentJsonToken.AsObject(), 'FormulaId').AsValue().AsText();
    //                 // if OrderFormulaId = ParentFormulaId then begin

    //                 ComponentAdded := false;
    //                 foreach ManufacturingOrderJsonToken in ManufacturingOrders
    //                 do begin
    //                     OrderFormulaId := GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'FormulaId').AsValue().AsText();
    //                     OrderComponentId := GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'ComponentId').AsValue().AsText();
    //                     if (OrderComponentId = ParentComponentId) and (OrderFormulaId = ParentFormulaId) then begin
    //                         ProductionSchedule.Init();


    //         ComponentStartDateTime := GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'StartDate').AsValue.AsDateTime();
    //         ComponentEndDateTime := GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'FinishDate').AsValue.AsDateTime();

    //                         // Message('Before:\\Component Start Date: %1\Component End Date: %2\Current: %3', Format(ComponentStartDateTime), Format(ComponentEndDateTime), Format(System.CurrentDateTime));

    //                         ManufacturingOrderActivityJsonObject := CreateMOActivity(ManufacturingOrderJsonToken, Act_Component_Id, ProductionSchedule);

    //                         DateTimeFromRecord := GetJsonToken(ManufacturingOrderActivityJsonObject, 'Start').AsValue.AsDateTime();
    //                         if System.DT2Time(DateTimeFromRecord) = 120000T then
    //                             DateTimeFromRecord := CreateDateTime(System.DT2Date(DateTimeFromRecord), 000000T);

    //                         // DateTimeFromRecord := GetDateFromMOText(GetJsonToken(ManufacturingOrderActivityJsonObject, 'Start').AsValue.AsText());
    //                         if (ComponentStartDateTime = 0DT) or (ComponentStartDateTime > DateTimeFromRecord) then
    //                             ComponentStartDateTime := DateTimeFromRecord;
    //                         if (FormulaStartDateTime = 0DT) or (FormulaStartDateTime > DateTimeFromRecord) then
    //                             FormulaStartDateTime := DateTimeFromRecord;

    //                         DateTimeFromRecord := GetJsonToken(ManufacturingOrderActivityJsonObject, 'End').AsValue.AsDateTime();
    //                         if System.DT2Time(DateTimeFromRecord) = 120000T then
    //                             DateTimeFromRecord := CreateDateTime(System.DT2Date(DateTimeFromRecord), 235959T);

    //                         // DateTimeFromRecord := GetDateFromMOText(GetJsonToken(ManufacturingOrderActivityJsonObject, 'End').AsValue.AsText());
    //                         if (ComponentEndDateTime = 0DT) or (DateTimeFromRecord > ComponentEndDateTime) then
    //                             ComponentEndDateTime := DateTimeFromRecord;
    //                         if (FormulaEndDateTime = 0DT) or (DateTimeFromRecord > FormulaEndDateTime) then
    //                             FormulaEndDateTime := DateTimeFromRecord;

    //                         // Message('After:\\Component Start Date: %1\Component End Date: %2', Format(ComponentStartDateTime), Format(ComponentEndDateTime));

    //                         // DateFromRecord := CalcDate('+10D', GetDateFromMOText(GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'FinishDate').AsValue.AsText()));
    //                         // if (ComponentEndDate = 0D) then // or (ComponentEndDate < DateFromRecord) then
    //                         //     ComponentEndDate := DateFromRecord;
    //                         // if (FormulaEndDate = 0D) then //or (FormulaEndDate < DateFromRecord) then
    //                         //     FormulaEndDate := DateFromRecord;


    //                         // ManufacturingOrderActivityJsonObject := createJsonObject();
    //                         // ManufacturingOrderActivityJsonObject.Add('ID', 'Act_ManufacturingOrder_' + GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue().AsText() + Format(Unique_Act_MO_Number));
    //                         // Unique_Act_MO_Number := Unique_Act_MO_Number + 1;
    //                         // ManufacturingOrderActivityJsonObject.Add('ParentID', Act_Component_Id);


    //                         // DateFromRecord := GetDateFromMOText(GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'StartDate').AsValue.AsText());
    //                         // ManufacturingOrderActivityJsonObject.Add('Start', CREATEDATETIME(DateFromRecord, 120000T));

    //                         // if (ComponentStartDate = 0D) or (ComponentStartDate > DateFromRecord) then
    //                         //     ComponentStartDate := DateFromRecord;
    //                         // if (FormulaStartDate = 0D) or (FormulaStartDate > DateFromRecord) then
    //                         //     FormulaStartDate := DateFromRecord;

    //                         // DateFromRecord := GetDateFromMOText(GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'FinishDate').AsValue.AsText());

    //                         // GoombahDate := CalcDate('+10D', DateFromRecord);
    //                         // DateFromRecord := GoombahDate;

    //                         // ManufacturingOrderActivityJsonObject.Add('End', CREATEDATETIME(DateFromRecord, 120000T));

    //                         // if (ComponentEndDate = 0D) or (ComponentEndDate < DateFromRecord) then
    //                         //     ComponentEndDate := DateFromRecord;
    //                         // if (FormulaEndDate = 0D) or (FormulaEndDate < DateFromRecord) then
    //                         //     FormulaEndDate := DateFromRecord;

    //                         // ManufacturingOrderActivityJsonObject.Add('BarShape', 0);
    //                         // ManufacturingOrderActivityJsonObject.Add('TableText', 'BorP:' + GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText());
    //                         // ManufacturingOrderActivityJsonObject.Add('Color', '#e69500');
    //                         // ManufacturingOrderActivityJsonObject.Add('BarText', GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText());

    //                         // IsABatch := GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'IsABatch').AsValue.AsBoolean();
    //                         // if IsABatch then
    //                         //     TempText := 'Batch'
    //                         // else
    //                         //     TempText := 'Planned Order';

    //                         // ManufacturingOrderActivityJsonObject.Add('TooltipText', 'Order Type: ' + TempText +
    //                         //     '<br>No.: ' + GetJsonToken(ManufacturingOrderJsonToken.AsObject(), 'BatchOrPlannedOrderNumber').AsValue.AsText() +
    //                         //     '<br>Due Date: ' + FORMAT(GoombahDate));

    //                         // ManufacturingOrderActivityJsonObject.Add('ContextMenuID', 'CM_Activity');
    //                         // ManufacturingOrderActivityJsonObject.Add('CollapseState', 0);

    //                         ManufacturingOrderActivities.Add(ManufacturingOrderActivityJsonObject);
    //                         ProductionSchedule.Insert();
    //                         ComponentAdded := true;
    //                         FormulaAdded := true;
    //                     end;
    //                 end;
    //                 if ComponentAdded then begin
    // //                    ComponentStartDateTime := CreateDateTime(ComponentStartDate, 0T);
    //                     ComponentActivityJsonObject.Add('Start', ComponentStartDateTime);
    // //                    ComponentEndDateTime := CreateDateTime(ComponentEndDate, 235959T);
    //                     ComponentActivityJsonObject.Add('End', ComponentEndDateTime);

    //                     ComponentActivityJsonObject.Add('TooltipText', 'Component ID: ' + ParentComponentId +
    //                     '<br>Start Date: ' + FORMAT(ComponentStartDateTime) +
    //                     '<br>Due Date: ' + FORMAT(ComponentEndDateTime));

    //                     ManufacturingOrderActivities.Add(ComponentActivityJsonObject);

    //                     ProductionSchedule.Init();
    //                     ProductionSchedule.ScheduleId := GetJsonToken(ComponentActivityJsonObject, 'ID').AsValue().AsText();
    //                     ProductionSchedule.ParentScheduleId := GetJsonToken(ComponentActivityJsonObject, 'ParentID').AsValue().AsText();
    //                     ProductionSchedule.RecordType := VICVisualObjectType::SummaryActivity;
    //                     ProductionSchedule.Insert();
    //                 end;
    //             end;
    //             if FormulaAdded then begin
    // //                TempDateTime := CreateDateTime(FormulaStartDate, 0T);
    //                 FormulaActivityJsonObject.Add('Start', FormulaStartDateTime);
    //                 // TempDateTime := CreateDateTime(FormulaEndDate, 0T);
    //                 FormulaActivityJsonObject.Add('End', FormulaEndDateTime);

    //                 FormulaActivityJsonObject.Add('TooltipText', 'Formula ID: ' + ParentFormulaId +
    //                 '<br>Start Date: ' + FORMAT(FormulaStartDateTime) +
    //                 '<br>Due Date: ' + FORMAT(FormulaEndDateTime));

    //                 ManufacturingOrderActivities.Add(FormulaActivityJsonObject);

    //                 ProductionSchedule.Init();
    //                 ProductionSchedule.ScheduleId := GetJsonToken(FormulaActivityJsonObject, 'ID').AsValue().AsText();
    //                 ProductionSchedule.RecordType := VICVisualObjectType::SummaryActivity;
    //                 ProductionSchedule.Insert();
    //             end;
    //         end;

    //         ManufacturingOrderActivityLinkJsonObject := createJsonObject();
    //         ManufacturingOrderActivityLinkJsonObject.Add('ID', 'Link-1');
    //         ManufacturingOrderActivityLinkJsonObject.Add('SourceActivityID', 'Act_ManufacturingOrder_UNDO-817');
    //         ManufacturingOrderActivityLinkJsonObject.Add('TargetActivityID', 'Act_ManufacturingOrder_V4-2048-16');
    //         ManufacturingOrderActivityLinks.Add(ManufacturingOrderActivityLinkJsonObject);
    //         ManufacturingOrderActivityLinkJsonObject := createJsonObject();
    //         ManufacturingOrderActivityLinkJsonObject.Add('ID', 'Link-2');
    //         ManufacturingOrderActivityLinkJsonObject.Add('SourceActivityID', 'Act_ManufacturingOrder_UNDO-716');
    //         ManufacturingOrderActivityLinkJsonObject.Add('TargetActivityID', 'Act_ManufacturingOrder_UNDO-817');
    //         ManufacturingOrderActivityLinkJsonObject.Add('TooltipText', 'This is a test <br>of link tooltip.');
    //         ManufacturingOrderActivityLinks.Add(ManufacturingOrderActivityLinkJsonObject);
    //     end;

    //     procedure LoadActivities(pActivities: JsonArray; pStart: Date; pEnd: Date)
    //     var
    //         ldnActivity: JsonObject;
    //         lrecServiceHeader: Record 5900;
    //         lrecServiceItemLine: Record 5901;
    //     begin
    //         //Create Activities from Service Headers (Table 5900) and Service Item Lines (Table 5901)
    //         ldnActivity.Add('ID', 'Act_Service_Header');
    //         ldnActivity.Add('AddIn_TableText', 'Service Orders');
    //         pActivities.Add(ldnActivity);

    //         lrecServiceHeader.SETCURRENTKEY(lrecServiceHeader."Document Type", lrecServiceHeader."No.");
    //         lrecServiceHeader.SETRANGE(lrecServiceHeader."Document Type", lrecServiceHeader."Document Type"::Order);
    //         IF lrecServiceHeader.FIND('-') THEN
    //             REPEAT
    //                 ldnActivity := createJsonObject();
    //                 ldnActivity.Add('ID', 'Act_SH_' + FORMAT(lrecServiceHeader."No."));
    //                 ldnActivity.Add('ParentID', 'Act_Service_Header');
    //                 ldnActivity.Add('Start', CREATEDATETIME(lrecServiceHeader."Due Date", 120000T));
    //                 ldnActivity.Add('BarShape', 2);
    //                 ldnActivity.Add('AddIn_TableText', FORMAT(lrecServiceHeader."No.") + ' (' + FORMAT(lrecServiceHeader."Due Date") + ')');
    //                 ldnActivity.Add('Color', '#e69500');
    //                 ldnActivity.Add('AddIn_BarText', FORMAT(lrecServiceHeader."No."));
    //                 ldnActivity.Add('AddIn_TooltipText', 'Service Header' +
    //                   '<br>Document Type: ' + FORMAT(lrecServiceHeader."Document Type") +
    //                   '<br>No.: ' + FORMAT(lrecServiceHeader."No.") +
    //                   '<br>Start Date: ' + FORMAT(lrecServiceHeader."Starting Date") +
    //                   '<br>End Date: ' + FORMAT(lrecServiceHeader."Due Date"));
    //                 ldnActivity.Add('AddIn_ContextMenuID', 'CM_Activity');
    //                 ldnActivity.Add('CollapseState', 1);
    //                 pActivities.Add(ldnActivity);

    //                 lrecServiceItemLine.SETCURRENTKEY(lrecServiceItemLine."Document Type", lrecServiceItemLine."Document No.", lrecServiceItemLine."Line No.");
    //                 lrecServiceItemLine.SETRANGE(lrecServiceItemLine."Document Type", lrecServiceItemLine."Document Type"::Order);
    //                 lrecServiceItemLine.SETRANGE(lrecServiceItemLine."Document No.", lrecServiceHeader."No.");
    //                 IF lrecServiceItemLine.FIND('-') THEN
    //                     REPEAT
    //                         ldnActivity := createJsonObject();
    //                         ldnActivity.Add('ID', 'Act_SIL_' + FORMAT(lrecServiceHeader."No.") + '_' + FORMAT(lrecServiceItemLine."Line No."));
    //                         ldnActivity.Add('ParentID', 'Act_SH_' + FORMAT(lrecServiceHeader."No."));
    //                         ldnActivity.Add('Start', CREATEDATETIME(lrecServiceItemLine."Starting Date", lrecServiceItemLine."Starting Time"));
    //                         ldnActivity.Add('End', CREATEDATETIME(lrecServiceItemLine."Finishing Date", lrecServiceItemLine."Finishing Time"));
    //                         ldnActivity.Add('AddIn_TableText', FORMAT(lrecServiceItemLine."Line No.") + ' (' + FORMAT(lrecServiceItemLine.Description) + ')');
    //                         ldnActivity.Add('Color', '#e69500');
    //                         ldnActivity.Add('AddIn_BarText', FORMAT(lrecServiceItemLine."Line No."));
    //                         ldnActivity.Add('AddIn_TooltipText', 'Service Header' +
    //                           '<br>Document Type: ' + FORMAT(lrecServiceHeader."Document Type") +
    //                           '<br>No.: ' + FORMAT(lrecServiceHeader."No.") +
    //                           '<br>Line No.: ' + FORMAT(lrecServiceItemLine."Line No."));
    //                         ldnActivity.Add('AddIn_ContextMenuID', 'CM_Activity');
    //                         pActivities.Add(ldnActivity);
    //                     UNTIL lrecServiceItemLine.NEXT = 0;
    //             UNTIL lrecServiceHeader.NEXT = 0;
    //     end;

    //     procedure LoadAllocations(pActivities: JsonArray; pAllocations: JsonArray; pStart: Date; pEnd: Date)
    //     var
    //         ldnActivity: JsonObject;
    //         ldnAllocation: JsonObject;
    //         lrecSOAllocation: Record 5950;
    //         lrecJobPlanningLine: Record 1003;
    //         tempEntry: JsonObject;
    //         tempEntries: JsonArray;
    //         tempText: Text;
    //     begin
    //         //Create Allocations from Service Order Allocations (Table 5950)
    //         lrecSOAllocation.SETCURRENTKEY(lrecSOAllocation."Allocation Date", lrecSOAllocation.Status);
    //         lrecSOAllocation.SETRANGE(lrecSOAllocation.Status, lrecSOAllocation.Status::Active);
    //         lrecSOAllocation.SETRANGE(lrecSOAllocation."Allocation Date", pStart, pEnd);
    //         IF lrecSOAllocation.FIND('-') THEN
    //             REPEAT
    //                 IF (lrecSOAllocation."Resource No." <> '') THEN BEGIN
    //                     IF ((lrecSOAllocation."Starting Time" <> 0T) AND (lrecSOAllocation."Finishing Time" <> 0T)) THEN BEGIN
    //                         ldnAllocation := createJsonObject();
    //                         ldnAllocation.Add('ID', 'SOA_' + FORMAT(lrecSOAllocation."Entry No."));
    //                         ldnAllocation.Add('ActivityID', 'Act_SOA_' + FORMAT(lrecSOAllocation."Entry No."));
    //                         ldnAllocation.Add('ResourceID', 'R_' + lrecSOAllocation."Resource No.");
    //                         tempEntries := createJsonArray();
    //                         tempEntry := createJsonObject();
    //                         tempEntry.Add('Start', CREATEDATETIME(lrecSOAllocation."Allocation Date", lrecSOAllocation."Starting Time"));
    //                         tempEntry.Add('End', CREATEDATETIME(lrecSOAllocation."Allocation Date", lrecSOAllocation."Finishing Time"));
    //                         tempEntry.Add('Color', '#e69500');
    //                         tempEntries.Add(tempEntry);
    //                         ldnAllocation.Add('Entries', tempEntries);
    //                         ldnAllocation.Add('AddIn_BarText', 'Document No.: ' + lrecSOAllocation."Document No.");
    //                         ldnAllocation.Add('AddIn_TooltipText', 'Service Order Allocation:<br>Entry No.: ' + FORMAT(lrecSOAllocation."Entry No.") + '<br>Document No.: ' + FORMAT(lrecSOAllocation."Document No."));
    //                         ldnAllocation.Add('AddIn_ContextMenuID', 'CM_Allocation');
    //                         pAllocations.Add(ldnAllocation);
    //                     END;
    //                 END
    //                 ELSE BEGIN
    //                     IF (lrecSOAllocation."Resource Group No." <> '') THEN BEGIN
    //                         IF ((lrecSOAllocation."Starting Time" <> 0T) AND (lrecSOAllocation."Finishing Time" <> 0T)) THEN BEGIN
    //                             ldnAllocation := createJsonObject();
    //                             ldnAllocation.Add('ID', 'SOA_' + FORMAT(lrecSOAllocation."Entry No."));
    //                             ldnAllocation.Add('ActivityID', 'Act_SOA_' + FORMAT(lrecSOAllocation."Entry No."));
    //                             ldnAllocation.Add('ResourceID', 'RG1_' + lrecSOAllocation."Resource Group No.");
    //                             tempEntries := createJsonArray();
    //                             tempEntry := createJsonObject();
    //                             tempEntry.Add('Start', CREATEDATETIME(lrecSOAllocation."Allocation Date", lrecSOAllocation."Starting Time"));
    //                             tempEntry.Add('End', CREATEDATETIME(lrecSOAllocation."Allocation Date", lrecSOAllocation."Finishing Time"));
    //                             tempEntry.Add('Color', 'yellow');
    //                             tempEntries.Add(tempEntry);
    //                             ldnAllocation.Add('Entries', tempEntries);
    //                             ldnAllocation.Add('AddIn_BarText', 'Document No.: ' + lrecSOAllocation."Document No.");
    //                             ldnAllocation.Add('AddIn_TooltipText', 'Service Order Allocation:<br>Entry No.: ' + FORMAT(lrecSOAllocation."Entry No.") + '<br>Document No.: ' + FORMAT(lrecSOAllocation."Document No."));
    //                             ldnAllocation.Add('AddIn_ContextMenuID', 'CM_Allocation');
    //                             pAllocations.Add(ldnAllocation);
    //                         END;
    //                     END
    //                 END;
    //             UNTIL lrecSOAllocation.NEXT = 0;

    //         //Create Allocations from Job Planning Lines (Table 1003)
    //         lrecJobPlanningLine.SETCURRENTKEY(lrecJobPlanningLine.Type, lrecJobPlanningLine."Planning Date");
    //         lrecJobPlanningLine.SETRANGE(lrecJobPlanningLine.Type, lrecJobPlanningLine.Type::Resource);
    //         lrecJobPlanningLine.SETRANGE(lrecJobPlanningLine."Planning Date", pStart, pEnd);
    //         IF lrecJobPlanningLine.FIND('-') THEN
    //             REPEAT
    //                 tempText := 'JPL_' + FORMAT(lrecJobPlanningLine."Job No.") + '_' + FORMAT(lrecJobPlanningLine."Job Task No.") + '_' + FORMAT(lrecJobPlanningLine."Line No.");
    //                 ldnAllocation := createJsonObject();
    //                 ldnAllocation.Add('ID', tempText);
    //                 ldnAllocation.Add('ResourceID', 'R_' + lrecJobPlanningLine."No.");
    //                 tempEntries := createJsonArray();
    //                 tempEntry := createJsonObject();
    //                 tempEntry.Add('Start', CREATEDATETIME(lrecJobPlanningLine."Planning Date", 080000T));
    //                 tempEntry.Add('End', CREATEDATETIME(lrecJobPlanningLine."Planning Date", 160000T));
    //                 tempEntry.Add('Color', 'blue');
    //                 tempEntries.Add(tempEntry);
    //                 ldnAllocation.Add('Entries', tempEntries);
    //                 ldnAllocation.Add('AddIn_BarText', tempText);
    //                 ldnAllocation.Add('AddIn_TooltipText', 'Job Planning Line' +
    //                   '<br>Job No.: ' + FORMAT(lrecJobPlanningLine."Job No.") +
    //                   '<br>Job Task No.: ' + FORMAT(lrecJobPlanningLine."Job Task No.") +
    //                   '<br>Line No.: ' + FORMAT(lrecJobPlanningLine."Line No.") +
    //                   '<br>Description: ' + FORMAT(lrecJobPlanningLine.Description));
    //                 ldnAllocation.Add('AddIn_ContextMenuID', 'CM_Allocation');
    //                 pAllocations.Add(ldnAllocation);
    //             UNTIL lrecJobPlanningLine.NEXT = 0;
    //     end;

    //     procedure LoadEntities(pEntities: JsonArray)
    //     var
    //         ldnEntity: JsonObject;
    //         i: Integer;
    //         j: Integer;
    //         lchLetter: Char;
    //         tempEntityToken: JsonToken;
    //     begin
    //         FOR i := 65 TO 70 DO BEGIN
    //             lchLetter := i;
    //             ldnEntity := createJsonObject();
    //             ldnEntity.Add('ID', 'BA_Job_' + FORMAT(lchLetter));
    //             ldnEntity.Get('ID', tempEntityToken);
    //             ldnEntity.Add('TableColor', 'darkgreen');
    //             ldnEntity.Add('TableTextColor', 'white');
    //             ldnEntity.Add('AddIn_TooltipText', 'Backlog job:<br>' + FORMAT(tempEntityToken.AsValue().AsText()));
    //             ldnEntity.Add('AddIn_TableText', 'Job ' + FORMAT(lchLetter));
    //             IF (i = 66) THEN
    //                 ldnEntity.Add('CollapseState', 1);
    //             pEntities.Add(ldnEntity);
    //             FOR j := 1 TO 3 DO BEGIN
    //                 ldnEntity := createJsonObject();
    //                 ldnEntity.Add('ID', 'BA_Job_' + FORMAT(lchLetter) + '_Task_' + FORMAT(j));
    //                 ldnEntity.Add('TableColor', 'seagreen');
    //                 ldnEntity.Add('TableTextColor', 'white');
    //                 ldnEntity.Add('AddIn_TableText', 'Task ' + FORMAT(j));
    //                 ldnEntity.Get('ID', tempEntityToken);
    //                 ldnEntity.Add('AddIn_TooltipText', 'Backlog task:<br>' + FORMAT(tempEntityToken.AsValue().AsText()));
    //                 ldnEntity.Add('ParentID', 'BA_Job_' + FORMAT(lchLetter));
    //                 ldnEntity.Add('AddIn_ContextMenuID', 'CM_Entity');
    //                 pEntities.Add(ldnEntity);
    //             END
    //         END
    //     end;

    //     procedure LoadContextMenus(pContextMenus: JsonArray)
    //     var
    //         ldnContextMenu: JsonObject;
    //         ldnContextMenuItem: JsonObject;
    //         tempEntries: JsonArray;
    //     begin
    //         ldnContextMenu.Add('ID', 'CM_ResourceGroup');
    //         ldnContextMenuItem.Add('Text', 'ResourceGroup CM-Entry 01');
    //         ldnContextMenuItem.Add('Code', 'RG_01');
    //         ldnContextMenuItem.Add('SortCode', 'a');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'ResourceGroup CM-Entry 02');
    //         ldnContextMenuItem.Add('Code', 'RG_02');
    //         ldnContextMenuItem.Add('SortCode', 'b');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenu.Add('Items', tempEntries);
    //         pContextMenus.Add(ldnContextMenu);

    //         ldnContextMenu := createJsonObject();
    //         ldnContextMenu.Add('ID', 'CM_Resource');
    //         tempEntries := createJsonArray();
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Resource CM-Entry 01');
    //         ldnContextMenuItem.Add('Code', 'R_01');
    //         ldnContextMenuItem.Add('SortCode', 'a');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Resource CM-Entry 02');
    //         ldnContextMenuItem.Add('Code', 'R_02');
    //         ldnContextMenuItem.Add('SortCode', 'b');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenu.Add('Items', tempEntries);
    //         pContextMenus.Add(ldnContextMenu);

    //         ldnContextMenu := createJsonObject();
    //         ldnContextMenu.Add('ID', 'CM_Activity');
    //         tempEntries := createJsonArray();
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Activity CM-Entry 01');
    //         ldnContextMenuItem.Add('Code', 'A_01');
    //         ldnContextMenuItem.Add('SortCode', 'a');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Activity CM-Entry 02');
    //         ldnContextMenuItem.Add('Code', 'A_02');
    //         ldnContextMenuItem.Add('SortCode', 'b');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenu.Add('Items', tempEntries);
    //         pContextMenus.Add(ldnContextMenu);

    //         ldnContextMenu := createJsonObject();
    //         ldnContextMenu.Add('ID', 'CM_Allocation');
    //         tempEntries := createJsonArray();
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Allocation CM-Entry 01');
    //         ldnContextMenuItem.Add('Code', 'Al_01');
    //         ldnContextMenuItem.Add('SortCode', 'a');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Allocation CM-Entry 02');
    //         ldnContextMenuItem.Add('Code', 'Al_02');
    //         ldnContextMenuItem.Add('SortCode', 'b');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenu.Add('Items', tempEntries);
    //         pContextMenus.Add(ldnContextMenu);

    //         ldnContextMenu := createJsonObject();
    //         ldnContextMenu.Add('ID', 'CM_Entity');
    //         tempEntries := createJsonArray();
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Entity CM-Entry 01');
    //         ldnContextMenuItem.Add('Code', 'E_01');
    //         ldnContextMenuItem.Add('SortCode', 'a');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenuItem := createJsonObject();
    //         ldnContextMenuItem.Add('Text', 'Entity CM-Entry 02');
    //         ldnContextMenuItem.Add('Code', 'E_02');
    //         ldnContextMenuItem.Add('SortCode', 'b');
    //         tempEntries.Add(ldnContextMenuItem);
    //         ldnContextMenu.Add('Items', tempEntries);
    //         pContextMenus.Add(ldnContextMenu);
    //     end;

    local procedure GetDateForWebApiCall(DateToFormat: Date) FormattedDate: Text
    begin
        FormattedDate := Format(DateToFormat, 0, '<Year4>-<Month,2>-<Day,2>');
    end;

    procedure FetchPlanningItemQuantitiesFromWebApi(ItemId: Text) PlanningItemQuantities: JsonObject
    var
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseString: Text;
        RequestObject: JsonObject;
        JsonRequestObject: JsonObject;
        JsonRequestData: Text;
    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        Request.Method := 'POST';
        Request.SetRequestUri(StrSubstNo('%1/planning/planningitemquantities', VicinityApiUrl, VicinityCompanyId));
        Clear(RequestObject);
        Clear(JsonRequestObject);
        RequestObject.Add('VicinityCompanyId', VicinityCompanyId);
        RequestObject.Add('ComponentId', ItemId);
        RequestObject.WriteTo(JsonRequestData);
        Content.WriteFrom(JsonRequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then
            Error('Unable to retrieve planning item quantities.');
        Response.Content.ReadAs(ResponseString);
        PlanningItemQuantities.ReadFrom(ResponseString);     
    end;
}
