page 50410 VICProductionSchedule
{
    ApplicationArea = All;
    Caption = 'Vicinity Production Schedule';
    PageType = Card; //List; // Card; // Document; //List;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;
    // SourceTable = VICProductionSchedule;
    // SourceTableTemporary = true;
    // AnalysisModeEnabled = false;
    SourceTable = VICScheduleSettings;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(ScheduleSettings)
            {
                Caption = 'Settings';

                field(StartDate; ScheduleStartDate)
                {
                    Caption = 'Schedule Start Date';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;
                }

                field(EndDate; ScheduleEndDate)
                {
                    Caption = 'Schedule End Date';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;
                }

                field(Batches; Batches)
                {
                    Caption = 'Batches';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;
                }

                field(FirmPlannedOrders; FirmPlannedOrders)
                {
                    Caption = 'Firm Planned Orders';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;
                }

                field(UnfirmPlannedOrders; UnfirmedPlannedOrders)
                {
                    Caption = 'Unfirmed Planned Orders';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;
                }

                // field(GroupBy; ScheduleGroupBy)
                // {
                //     Caption = 'Group By';
                //     ApplicationArea = All;
                //     trigger OnValidate()
                //     begin
                //         ClearSchedule();
                //         DrawSchedule();
                //     end;
                // }

                field(DisplayResourcesWithNoActivity; DisplayResourcesWithNoActivity)
                {
                    Caption = 'Display Levels With No Activity';
                    trigger OnValidate()
                    begin
                        ClearSchedule();
                        DrawSchedule();
                    end;
                }

                field(Level1ScheduleGroupBy; LocalLevel1ScheduleGroupBy)
                {
                    Caption = 'Level 1';
                    ApplicationArea = All;
                    TableRelation = VICScheduleGroupBy.GroupBy WHERE(Level = const(1)); // where ("Description" <> filter(<>''));

                    trigger OnValidate()
                    var
                        VICScheduleGroupBy: Record VICScheduleGroupBy;
                    begin
                        if not VICScheduleGroupBy.Get(LocalLevel1ScheduleGroupBy) then begin
                            VICScheduleGroupBy.Get(SavedLocalLevel1ScheduleGroupBy);
                            LocalLevel1ScheduleGroupBy := VICScheduleGroupBy.GroupBy;
                        end
                        else begin
                            SavedLocalLevel1ScheduleGroupBy := LocalLevel1ScheduleGroupBy;
                        end;
                    end;
                }

                field(Level2ScheduleGroupBy; LocalLevel2ScheduleGroupBy)
                {
                    Caption = 'Level 2';
                    ApplicationArea = All;
                    TableRelation = VICScheduleGroupBy.GroupBy;

                    trigger OnValidate()
                    var
                        VICScheduleGroupBy: Record VICScheduleGroupBy;
                    begin
                        if not VICScheduleGroupBy.Get(LocalLevel2ScheduleGroupBy) then begin
                            VICScheduleGroupBy.Get(SavedLocalLevel2ScheduleGroupBy);
                            LocalLevel2ScheduleGroupBy := VICScheduleGroupBy.GroupBy;
                        end
                        else begin
                            SavedLocalLevel2ScheduleGroupBy := LocalLevel2ScheduleGroupBy;
                        end;
                    end;
                }
            }
            usercontrol(conVSControlAddIn; NetronicVSControlAddIn)
            {
                ApplicationArea = All;

                trigger OnRequestSettings(eventArgs: JsonObject)
                var
                    Settings: JsonObject;
                    SortCodeSources: JsonArray;
                begin
                    Settings.Add('LicenseKey', 'ODYxMTA1LTIxNDc0OS04NzY1Ny17InciOiIiLCJpZCI6IlZTQ0FJMDAyMCIsIm4iOiJWaWNpbml0eSBTb2Z0d2FyZSIsInUiOiIiLCJlIjo5OTEyLCJ2IjoiNC4wIiwiZiI6WzEwMDFdLCJlZCI6IkJhc2UifQ==');
                    Settings.Add('Start', ScheduleStartDate);
                    Settings.Add('End', ScheduleEndDate);
                    Settings.Add('ViewType', ViewType::ActivityView);
                    // Settings.Add('ViewType', ViewType::ResourceView);
                    Settings.Add('WorkDate', CREATEDATETIME(WORKDATE(), 000000T));
                    Settings.Add('TitleText', 'Batches and Planned Orders');
                    // Settings.Add('TimeZone', 'Eastern Standard Time');
                    Settings.Add('TimeZone', 'Pacific Standard Time');


                    // _settings.Add('EntitiesTableWidth', gintconVSControlAddInEntitiesTableWidth);
                    // _settings.Add('EntitiesTableViewWidth', gintconVSControlAddInEntitiesTableViewWidth);

                    Settings.Add('TableWidth', 500);
                    Settings.Add('TableViewWidth', 500);
                    Settings.Add('ActivitiesTableViewWidth', 500);
                    Settings.Add('UpdateMode', 3);

                    Settings.Add('DefaultActivityAllowedBarDragModes', VICScheduleDragMode::DragHorizontally.AsInteger() + VICScheduleDragMode::DragStart.AsInteger() + VICScheduleDragMode::DragEnd.AsInteger());

                    SortCodeSources.Add('TableText');
                    Settings.Add('ActivitySortCodeSources', SortCodeSources.AsToken());

                    CurrPage.conVSControlAddIn.SetSettings(Settings);


                    // gbAddInInitialized := TRUE;
                end;

                trigger OnControlAddInReady()
                var
                begin
                    DrawSchedule();
                end;

                trigger OnSelectionChanged(eventArgs: JsonObject)
                var
                    Token: JsonToken;
                    ObjectType: Integer;
                    ObjectID: Text;
                    VisualType: Integer;

                    _jsonArray: JsonArray;
                begin
                    if (eventArgs.Get('ObjectType', Token)) then
                        ObjectType := Token.AsValue().AsInteger()
                    else
                        ObjectType := 0;

                    if (eventArgs.Get('ObjectID', Token)) then
                        ObjectID := Token.AsValue().AsText()
                    else
                        ObjectID := '';

                    if (eventArgs.Get('VisualType', Token)) then
                        VisualType := Token.AsValue().AsInteger()
                    else
                        VisualType := -1;

                    TempVICProductionSchedule.Reset();
                    TempVICProductionSchedule.SetCurrentKey(ScheduleObjectId);
                    TempVICProductionSchedule.ScheduleObjectId := ObjectID;

                    if VisualType = 1 then begin    
                        CurrPage.conVSControlAddIn.ScrollToObject(1, ObjectID, 0, false);
                        _jsonArray.Add(ObjectID);
                        CurrPage.conVSControlAddIn.SelectObjects(1, _jsonArray, 1);                       
                    end;
                end;

                trigger OnDrop(eventArgs: JsonObject)
                var
                    DragMode: Enum VICScheduleDragMode;
                    TempJsonArray: JsonArray;
                    PlanningScheduleDetails: JsonArray;
                    PlanningScheduleDetail: JsonObject;
                    VICJSONUtilities: Codeunit VICJSONUtilities;
                    VICProdScheduleManagement: Codeunit VICProdScheduleManagement;
                    NewStart: DateTime;
                    NewEnd: DateTime;



                    JsonToken: JsonToken;
                    ObjectType: Integer;
                    ObjectID: Text;
                    NewRowObjectType: Integer;
                    NewRowObjectID: Text;
                    RowInsertionMode: Integer;
                    ObjectDragMode: Integer;
                    TempText: Text;
                    TempJsonValue: JsonValue;
                begin
                    if (eventArgs.Get('ObjectType', JsonToken)) then
                        ObjectType := JsonToken.AsValue().AsInteger()
                    else
                        ObjectType := 0;

                    if (eventArgs.Get('ObjectID', JsonToken)) then
                        ObjectID := JsonToken.AsValue().AsText()
                    else
                        ObjectID := '';

                    if (eventArgs.Get('NewRowObjectType', JsonToken)) then
                        NewRowObjectType := JsonToken.AsValue().AsInteger()
                    else
                        NewRowObjectType := 0;

                    if (eventArgs.Get('NewRowObjectID', JsonToken)) then
                        NewRowObjectID := JsonToken.AsValue().AsText()
                    else
                        NewRowObjectID := '';

                    if (eventArgs.Get('DragMode', JsonToken)) then
                        DragMode := Enum::VICScheduleDragMode.FromInteger(JsonToken.AsValue().AsInteger())
                    else
                        DragMode := DragMode::None;

                    if (eventArgs.Get('NewStart', JsonToken)) then begin
                        JsonToken.AsValue().WriteTo(TempText);
                        TempJsonValue.SetValue(CopyStr(TempText, 2, 19) + 'Z');
                        NewStart := TempJsonValue.AsDateTime();
                    end;

                    if (eventArgs.Get('NewEnd', JsonToken)) then begin
                        JsonToken.AsValue().WriteTo(TempText);
                        TempJsonValue.SetValue(CopyStr(TempText, 2, 19) + 'Z');
                        NewEnd := TempJsonValue.AsDateTime();
                    end;

                    if (eventArgs.Get('RowInsertionMode', JsonToken)) then
                        RowInsertionMode := JsonToken.AsValue().AsInteger()
                    else
                        RowInsertionMode := 0;

                    if (DragMode = VICScheduleDragMode::DragHorizontally) or (DragMode = VICScheduleDragMode::DragStart) or (DragMode = VICScheduleDragMode::DragEnd) then begin
                        TempJsonArray := ProcessVerticalDragDrop(ObjectID, NewStart, NewEnd);
                        if TempJsonArray.Count = 0 then
                            exit;

                        // Update Vicinity via web service.
                        PlanningScheduleDetails := VICJSONUtilities.CreateJsonArray();
                        PlanningScheduleDetail := VICJSONUtilities.CreateJsonObject();

                        // Update production schedule.
                        if TempVICProductionSchedule.Get(ObjectID) then begin
                            PlanningScheduleDetail.Add('BatchOrPlannedOrderNumber', TempVICProductionSchedule.OrderNumber);
                            PlanningScheduleDetail.Add('FacilityId', TempVICProductionSchedule.FacilityId);
                            PlanningScheduleDetail.Add('IsABatch', TempVICProductionSchedule.IsABatch);
                            PlanningScheduleDetail.Add('PlanStartDate', TempVICProductionSchedule.StartDateTime);
                            PlanningScheduleDetail.Add('PlanEndDate', TempVICProductionSchedule.EndDateTime);
                            PlanningScheduleDetail.Add('ProcessCellId', TempVICProductionSchedule.ProcessCellId);
                            PlanningScheduleDetail.Add('FillUnitId', TempVICProductionSchedule.FillUnitId);
                            PlanningScheduleDetails.Add(PlanningScheduleDetail);
                            VICProdScheduleManagement.PostScheduleUpdate(PlanningScheduleDetails);
                        end;

                        CurrPage.conVSControlAddIn.UpdateActivities(TempJsonArray);
                        CurrPage.conVSControlAddIn.Render();
                    end
                    else begin
                        if (DragMode = VICScheduleDragMode::DragVertically) or (DragMode.AsInteger() = (VICScheduleDragMode::DragVertically.AsInteger() + VICScheduleDragMode::DragHorizontally.AsInteger())) then begin
                            // Horizontal

                        end;
                    end;
                end;

                trigger OnContextMenuItemClicked(eventArgs: JsonObject)
                var
                begin

                end;

                trigger OnDoubleClicked(eventArgs: JsonObject)
                var
                    JsonToken: JsonToken;
                    ObjectID: Text;
                    DrillbackId: Integer;
                    Drillback: Text;
                    VicinityDrillback: Record VICDrillback;
                begin
                    if eventArgs.Get('ObjectID', JsonToken) then begin
                        ObjectID := JsonToken.AsValue().AsText();
                        TempVICProductionSchedule.ScheduleObjectId := ObjectID;
                        if TempVICProductionSchedule.Find('=') then begin
                            if TempVICProductionSchedule.IsABatch then
                                DrillbackId := 1
                            else
                                DrillbackId := 9;
                            VicinityDrillback.SetCurrentKey("Drillback ID");
                            VicinityDrillback.SetRange("Drillback ID", DrillbackId);
                            if VicinityDrillback.Find('-') then begin
                                Drillback := VicinityDrillback."Drillback Hyperlink";
                                if DrillbackId = 1 then
                                    Drillback := Drillback + '&FacilityID=' + TempVICProductionSchedule.FacilityId + '&BatchNumber=' + TempVICProductionSchedule.OrderNumber
                                else
                                    Drillback := Drillback + '&FacilityID=' + TempVICProductionSchedule.FacilityId + '&PlannedOrderNumber=' + TempVICProductionSchedule.OrderNumber;
                                HyperLink(Drillback);
                            end;
                        end;
                    end;
                end;
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(FiltersActionRef; FiltersAction)
            {
            }
            actionref(ClearFiltersActionRef; ClearFiltersAction)
            {
            }
            actionref(RefreshActionRef; RefreshAction)
            {
            }

        }
        area(Processing)
        {
            action(FiltersAction)
            {
                Caption = 'Filters';
                Image = Filter;
                Visible = true;
                trigger OnAction()
                var
                    FilterPageId: Integer;
                begin
                    FilterPageId := PAGE::VICProductionScheduleFilter;
                    PAGE.RunModal(FilterPageId, TempVICProductionScheduleFilter);
                    TempVICProductionScheduleFilter.FindFirst();
                    ClearSchedule();
                    DrawSchedule();
                end;
            }

            action(ClearFiltersAction)
            {
                Caption = 'Clear Filters';
                Image = ClearFilter;
                Visible = true;
                trigger OnAction()
                begin
                    TempVICProductionScheduleFilter.DeleteAll();
                    TempVICProductionScheduleFilter.Init();
                    TempVICProductionScheduleFilter.Insert(true);
                    ClearSchedule();
                    DrawSchedule();
                end;
            }

            action(RefreshAction)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Visible = true;
                trigger OnAction()
                var
                    Settings: JsonObject;
                begin
                    ClearSchedule();
                    LoadData();
                    DrawSchedule();
                end;
            }
        }
    }

    var
        Activities: JsonArray;
        ScheduleGroupBy: Enum VICScheduleGroupBy;
        DisplayResourcesWithNoActivity: Boolean;
        ViewType: Option ActivityView,ResourceView;
        ScheduleEndDate: Date;
        ScheduleStartDate: Date;
        SelectedObjectId: Text;
        LocalLevel1ScheduleGroupBy: Text[50];
        LocalLevel2ScheduleGroupBy: Text[50];
        SavedLocalLevel1ScheduleGroupBy: Text[50];
        SavedLocalLevel2ScheduleGroupBy: Text[50];
        VICJsonUtilities: Codeunit VICJSONUtilities;
        TempVICResource: Record VICResource temporary;
        TempVICScheduleResource: Record VICScheduleResource temporary;
        TempVICProductionSchedule: Record VICProductionSchedule temporary;
        TempVICFormula: Record VICFormula temporary;
        TempVICComponent: Record VICComponent temporary;
        TempVICProductionScheduleFilter: Record VICScheduleFilter temporary;
        UniqueIdCounter: Integer;
        Batches: Boolean;
        FirmPlannedOrders: Boolean;
        UnfirmedPlannedOrders: Boolean;
        Facility: Label 'Facility';
        ProcessCell: Label 'Process Cell';
        FillUnit: Label 'Fill Unit';

    trigger OnOpenPage()
    var
        UnderscorePos: Integer;
        VICScheduleGroupByRec: record VICScheduleGroupBy;
        ScheduleStartDateTime: DateTime;
        ScheduleEndDateTime: DateTime;

        // VICScheduleSettings: Record VICScheduleSettings;

    begin
        TempVICProductionScheduleFilter.Insert(true);
        if (Rec.PrimaryKey <> 'SETTING') then
            Rec.Get('SETTING');

        // VICScheduleSettings.Reset();
        // VICScheduleSettings.DeleteAll();
        // VICScheduleSettings.Init();
        // VICScheduleSettings."PrimaryKey" := 'SETTING';
        // VICScheduleSettings.Level1ScheduleGroupBy := Facility; // 'Facility';
        // VICScheduleSettings.Level2ScheduleGroupBy := ProcessCell; // 'Process Cell';// VICScheduleGroupBy::FillUnit;
        //                                                           // OnOpenPageOnBeforeRecInsert(Rec);
        // VICScheduleSettings.Insert();

        // if not VICScheduleSettings.Get('SETTING') then begin
        //     VICScheduleSettings.Init();
        //     VICScheduleSettings."PrimaryKey" := 'SETTING';
        //     VICScheduleSettings.Level1ScheduleGroupBy := 'Process Cell';// VICScheduleGroupBy::FillUnit;
        //     VICScheduleSettings.Insert();
        // end;

        Batches := true;
        FirmPlannedOrders := true;
        UnfirmedPlannedOrders := true;

        // LoadData retrieves planning attribute information.
        LoadData();

        VICScheduleGroupByRec.Reset();
        VICScheduleGroupByRec.DeleteAll();
        if not VICScheduleGroupByRec.Get() then begin
            VICScheduleGroupByRec.Init();
            VICScheduleGroupByRec.GroupBy := Facility;
            VICScheduleGroupByRec.Description := Facility;
            VICScheduleGroupByRec.Type := VICScheduleGroupBy::Facility;
            VICScheduleGroupByRec.Level := 1;
            VICScheduleGroupByRec.Insert();
            VICScheduleGroupByRec.Init();
            VICScheduleGroupByRec.GroupBy := ProcessCell;
            VICScheduleGroupByRec.Description := ProcessCell;
            VICScheduleGroupByRec.Type := VICScheduleGroupBy::ProcessCell;
            VICScheduleGroupByRec.Level := 1;
            VICScheduleGroupByRec.Insert();
            VICScheduleGroupByRec.Init();
            VICScheduleGroupByRec.GroupBy := FillUnit;
            VICScheduleGroupByRec.Description := FillUnit;
            VICScheduleGroupByRec.Type := VICScheduleGroupBy::FillUnit;
            VICScheduleGroupByRec.Level := 1;
            VICScheduleGroupByRec.Insert();
            TempVICResource.SetRange(ResourceType, VICScheduleGroupBy::PlanningAttribute);
            if TempVICResource.FindFirst() then begin
                UnderscorePos := StrPos(TempVICResource.Description, '_');
                VICScheduleGroupByRec.GroupBy := Text.DelStr(TempVICResource.Description, UnderscorePos);
                VICScheduleGroupByRec.Description := VICScheduleGroupByRec.GroupBy;
                VICScheduleGroupByRec.Type := VICScheduleGroupBy::PlanningAttribute;
                VICScheduleGroupByRec.Level := 1;
                VICScheduleGroupByRec.Insert();
            end;
            VICScheduleGroupByRec.Init();
            VICScheduleGroupByRec.GroupBy := '';
            VICScheduleGroupByRec.Description := '';
            VICScheduleGroupByRec.Type := VICScheduleGroupBy::Blank;
            VICScheduleGroupByRec.Level := 2;
            VICScheduleGroupByRec.Insert();
        end;

        SetGroupByLevels();

        DisplayResourcesWithNoActivity := false;
        ScheduleStartDate := WorkDate() - 30;
        ScheduleEndDate := WorkDate() + 90;
        TempVICProductionSchedule.SetCurrentKey(StartDateTime);
        if TempVICProductionSchedule.FindFirst() then begin
            ScheduleStartDate := System.CalcDate('<-6W>', System.DT2Date(TempVICProductionSchedule.StartDateTime));
            ScheduleStartDateTime := CreateDateTime(ScheduleStartDate, 0T);
        end;
        TempVICProductionSchedule.SetCurrentKey(EndDateTime);
        if TempVICProductionSchedule.FindLast() then begin
            ScheduleEndDate := System.CalcDate('<+1M>', System.DT2Date(TempVICProductionSchedule.EndDateTime));
            ScheduleEndDateTime := CreateDateTime(ScheduleEndDate, 235959T);
        end;
        ViewType := ViewType::ActivityView;
        ScheduleGroupBy := ScheduleGroupBy::Facility;
    end;

    local procedure SetGroupByLevels()
    begin
        LocalLevel1ScheduleGroupBy := Facility;
        SavedLocalLevel1ScheduleGroupBy := LocalLevel1ScheduleGroupBy;
        LocalLevel2ScheduleGroupBy := '';
        SavedLocalLevel2ScheduleGroupBy := '';
    end;

    local procedure ScrollToActivity(ObjectId: Text)
    var
    begin
        CurrPage.conVSControlAddIn.ScrollToObject(1, ObjectId, 0, false);
    end;

    local procedure ClearSchedule()
    var
        JsonArrayContainer: JsonArray;
    begin
        CurrPage.conVSControlAddIn.RemoveAll();
    end;

    local procedure SetScheduleRanges(ScheduleRanges: JsonArray; var ResourceStartDate: DateTime; var ResourceEndDate: DateTime)
    var
        ScheduleRangeToken: JsonToken;
        RangeType: Enum VICScheduleGroupBy;
        RangeResourceId: Text;
        UnderScorePos: Integer;
        PlanningAttributeId: Text;
        PlanningAttributeValue: Integer;
    begin

        TempVICProductionSchedule.Reset();
        TempVICProductionSchedule.Reset();
        if not TempVICProductionScheduleFilter.IsEmpty then begin
            TempVICProductionSchedule.SetFilter(OrderNumber, TempVICProductionScheduleFilter.OrderNumber);
            TempVICProductionSchedule.SetFilter(FormulaId, TempVICProductionScheduleFilter.Formula);
        end;

        // if Filters <> '' then 
        //     TempVICProductionSchedule.SetFilter(OrderNumber, Filters);

        TempVICProductionSchedule.SetCurrentKey(StartDateTime);
        foreach ScheduleRangeToken in ScheduleRanges do begin
            RangeType := Enum::VICScheduleGroupBy.FromInteger(VICJsonUtilities.GetJsonToken(ScheduleRangeToken.AsObject(), 'ResourceType').AsValue().AsInteger());
            RangeResourceId := VICJsonUtilities.GetJsonToken(ScheduleRangeToken.AsObject(), 'ResourceId').AsValue().AsText();
            case RangeType of
                VICScheduleGroupBy::Facility:
                    TempVICProductionSchedule.SetRange(FacilityId, RangeResourceId);
                VICScheduleGroupBy::ProcessCell:
                    TempVICProductionSchedule.SetRange(ProcessCellId, RangeResourceId);
                VICScheduleGroupBy::FillUnit:
                    TempVICProductionSchedule.SetRange(FillUnitId, RangeResourceId);
                VICScheduleGroupBy::PlanningAttribute:
                    begin
                        // Example:
                        // ID: BIGFOOT
                        // Description: BIGFOOT_1 where 1 is the planning attribute id.
                        TempVICResource.Reset();
                        TempVICResource.SetRange(ResourceId, RangeResourceId);
                        if TempVICResource.FindFirst() then begin
                            UnderscorePos := StrPos(TempVICResource.Description, '_');
                            PlanningAttributeId := TempVICResource.Description.Substring(UnderScorePos + 1);
                            Evaluate(PlanningAttributeValue, PlanningAttributeId);
                            TempVICProductionSchedule.SetRange(PlanningAttributeValue, PlanningAttributeValue)
                        end
                        else begin
                            TempVICProductionSchedule.SetRange(PlanningAttributeValue, -999)
                        end;
                    end
            end;
        end;
        ResourceStartDate := 0DT;
        ResourceEndDate := 0DT;
        if TempVICProductionSchedule.FindFirst() then
            ResourceStartDate := TempVICProductionSchedule.StartDateTime;
        TempVICProductionSchedule.SetCurrentKey(EndDateTime);
        if TempVICProductionSchedule.FindLast() then
            ResourceEndDate := TempVICProductionSchedule.EndDateTime;
    end;

    local procedure AddAnOrderToActivities(ScheduleObjectId: Text)
    var
        OrderActivity: JsonObject;

    begin
        OrderActivity := VICJSONUtilities.CreateJsonObject();
        OrderActivity.Add('ID', TempVICProductionSchedule.ScheduleObjectId);
        OrderActivity.Add('ParentID', ScheduleObjectId); // TempVICScheduleResource.ScheduleObjectId);
        if System.DT2Time(TempVICProductionSchedule.StartDateTime) = 120000T then
            OrderActivity.Add('Start', CreateDateTime(System.DT2Date(TempVICProductionSchedule.StartDateTime), 0T))
        else
            OrderActivity.Add('Start', TempVICProductionSchedule.StartDateTime);

        if System.DT2Time(TempVICProductionSchedule.EndDateTime) = 120000T then
            OrderActivity.Add('End', CreateDateTime(System.DT2Date(TempVICProductionSchedule.EndDateTime + 10), 235959T))
        else
            OrderActivity.Add('End', TempVICProductionSchedule.EndDateTime + 10);

        OrderActivity.Add('BarShape', 0);    // rectangle
                                             // OrderActivity.Add('AllowedBarDragModes', 15);
        OrderActivity.Add('TableText', TempVICProductionSchedule.OrderNumber + ' [' + TempVICProductionSchedule.FormulaId + ']');
        OrderActivity.Add('BarText', TempVICProductionSchedule.OrderNumber);
        OrderActivity.Add('RowInsertionMode', 1);

        if TempVICProductionSchedule.RecordType = VICVisualObjectType::BatchActivity
        then begin
            OrderActivity.Add('Color', 'blue');
            OrderActivity.Add('ContextMenuID', 'CM_Activities');
        end
        else begin
            OrderActivity.Add('Color', '#e69500');
        end;

        OrderActivity.Add('TooltipText', GetActivityTooltipText(TempVICProductionSchedule));

        // OrderActivity.Add('ContextMenuID', 'CM_Activities');
        OrderActivity.Add('CollapseState', 0);

        OrderActivity.Add('BarSortMode', 1);
        OrderActivity.Add('RowSortMode', 1);

        Activities.Add(OrderActivity);

    end;

    local procedure LoadGroupingsForChildGroups(VICScheduleGroupBys: List of [Enum VICScheduleGroupBy]; Level: Integer; ParentObjectId: Text; ScheduleRanges: JsonArray; Activities: JsonArray)
    var
        ScheduleObjectId: Text;
        TableText: Text;
        ScheduleRange: JsonObject;
        VICJSONUtilities: Codeunit VICJSONUtilities;
        LocalTempVICResource: Record VICResource temporary;
        OrderActivity: JsonObject;
        ResourceStartDate: DateTime;
        ResourceEndDate: DateTime;
    begin
        if Level > VICScheduleGroupBys.Count then
            exit;

        // Make a local copy of VICResource table so recursion will work.
        TempVICResource.Reset();
        TempVICResource.SetCurrentKey(ResourceId);
        TempVICResource.SetRange(ResourceType, VICScheduleGroupBys.Get(Level));
        if TempVICResource.FindSet() then begin
            repeat
                LocalTempVICResource.Init();
                LocalTempVICResource := TempVICResource;
                LocalTempVICResource.Insert();
            until TempVICResource.Next() = 0;
        end;

        LocalTempVICResource.SetCurrentKey(ResourceId);
        LocalTempVICResource.SetAscending(ResourceId, true);
        if LocalTempVICResource.FindSet() then begin
            repeat
                UniqueIdCounter := UniqueIdCounter + 1;
                ScheduleObjectId := 'L' + Format(Level) + '_' + LocalTempVICResource.ScheduleObjectId + Format(UniqueIdCounter);
                ScheduleRange := VICJSONUtilities.CreateJsonObject();
                ScheduleRange.Add('ResourceType', Format(LocalTempVICResource.ResourceType.AsInteger()));
                ScheduleRange.Add('ResourceId', LocalTempVICResource.ResourceId);
                ScheduleRanges.Add(ScheduleRange);
                SetScheduleRanges(ScheduleRanges, ResourceStartDate, ResourceEndDate);
                if DisplayResourcesWithNoActivity or (ResourceStartDate <> 0DT) then begin
                    Activities.Add(NewResourceActivity(ResourceStartDate, ResourceEndDate, ScheduleObjectId, ParentObjectId, LocalTempVICResource));

                    TempVICScheduleResource.Init();
                    TempVICScheduleResource.ResourceId := LocalTempVICResource.ResourceId;
                    TempVICScheduleResource.ResourceType := LocalTempVICResource.ResourceType;
                    TempVICScheduleResource.Level := Level;
                    TempVICScheduleResource.ScheduleObjectId := ScheduleObjectId;
                    TempVICScheduleResource.ParentId := ParentObjectId;
                    TempVICScheduleResource.Insert();



                    if Level = VICScheduleGroupBys.Count then begin
                        if TempVICProductionSchedule.FindSet() then
                            repeat
                                AddAnOrderToActivities(ScheduleObjectId);
                                TempVICProductionSchedule.ScheduleResourceObjectId := ScheduleObjectId;
                                TempVICProductionSchedule.Modify();
                            until TempVICProductionSchedule.Next() = 0;
                    end;
                end;

                // Recursively drill down into next level groups.
                LoadGroupingsForChildGroups(VICScheduleGroupBys, Level + 1, ScheduleObjectId, ScheduleRanges, Activities);
            until LocalTempVICResource.Next() = 0;
        end;
    end;

    // // CHICAGO
    // //      LINE0
    // //      LINE1
    // //      LINE2
    // // GEORGIA
    // //      LINE0
    // //      LINE1
    // //      LINE2
    // // 
    // // 

    local procedure LoadGroupings(VICScheduleGroupBys: List of [Enum VICScheduleGroupBy]; NumberOfLevels: Integer; Activities: JsonArray)
    var
        ScheduleRanges: JsonArray;
        ScheduleRange: JsonObject;
        ScheduleObjectId: Text;
        ResourceStartDate: DateTime;
        ResourceEndDate: DateTime;
        LocalTempVICResource: Record VICResource temporary;
    begin
        TempVICResource.Reset();
        TempVICResource.SetCurrentKey(ResourceId);
        TempVICResource.SetRange(ResourceType, VICScheduleGroupBys.Get(1));
        if TempVICResource.FindSet() then
            repeat
                LocalTempVICResource.Init();
                LocalTempVICResource := TempVICResource;
                LocalTempVICResource.Insert;
            until TempVICResource.Next() = 0;

        LocalTempVICResource.SetCurrentKey(ResourceId);
        LocalTempVICResource.SetAscending(ResourceId, true);

        if LocalTempVICResource.FindSet() then
            repeat
                ScheduleRanges := VICJSONUtilities.CreateJsonArray();
                ScheduleRange := VICJSONUtilities.CreateJsonObject();
                ScheduleRange.Add('ResourceType', LocalTempVICResource.ResourceType.AsInteger());
                ScheduleRange.Add('ResourceId', LocalTempVICResource.ResourceId);
                ScheduleRanges.Add(ScheduleRange);

                SetScheduleRanges(ScheduleRanges, ResourceStartDate, ResourceEndDate);

                if DisplayResourcesWithNoActivity or (ResourceStartDate <> 0DT) then begin
                    UniqueIdCounter := UniqueIdCounter + 1;
                    ScheduleObjectId := 'L1_' + LocalTempVICResource.ScheduleObjectId + Format(UniqueIdCounter);
                    Activities.Add(NewResourceActivity(ResourceStartDate, ResourceEndDate, ScheduleObjectId, '', LocalTempVICResource));

                    TempVICScheduleResource.Init();
                    TempVICScheduleResource.ResourceId := TempVICResource.ResourceId;
                    TempVICScheduleResource.ResourceType := TempVICResource.ResourceType;
                    TempVICScheduleResource.Level := 1;
                    TempVICScheduleResource.ScheduleObjectId := ScheduleObjectId;
                    TempVICScheduleResource.ParentId := '';
                    TempVICScheduleResource.Insert();

                    if VICScheduleGroupBys.Count = 1 then begin
                        if TempVICProductionSchedule.FindSet() then
                            repeat
                                AddAnOrderToActivities(ScheduleObjectId);
                                TempVICProductionSchedule.ScheduleResourceObjectId := ScheduleObjectId;
                                TempVICProductionSchedule.Modify();
                            until TempVICProductionSchedule.Next() = 0;
                    end
                    else begin
                        LoadGroupingsForChildGroups(VICScheduleGroupBys, 2, ScheduleObjectId, ScheduleRanges, Activities);
                    end;
                end;
            until LocalTempVICResource.Next() = 0;
    end;

    local procedure DrawSchedule()
    var
        ContextMenus: JsonArray;
        ContextMenu: JsonObject;
        ContextMenuItem: JsonObject;
        TempContextMenuItems: JsonArray;
        FirstActivityId: Text;
        VICScheduleGroupByRec: record VICScheduleGroupBy;
        VICLevel1ScheduleGroupByToDisplay: Enum VICScheduleGroupBy;
        VICLevel2ScheduleGroupByToDisplay: Enum VICScheduleGroupBy;
        VICScheduleGroupBys: List of [Enum VICScheduleGroupBy];
        VICJSONUtilities: Codeunit VICJSONUtilities;
    begin
        TempVICScheduleResource.Reset();
        TempVICScheduleResource.DeleteAll();

        // Default to facility grouping.
        VICLevel1ScheduleGroupByToDisplay := VICScheduleGroupBy::Facility;

        // Get level 1 grouping.
        if VICScheduleGroupByRec.Get(LocalLevel1ScheduleGroupBy) then begin
            VICLevel1ScheduleGroupByToDisplay := VICScheduleGroupByRec.Type;
            VICScheduleGroupBys.Add(VICLevel1ScheduleGroupByToDisplay);
        end;

        // Get level 2 grouping.
        if VICScheduleGroupByRec.Get(LocalLevel2ScheduleGroupBy) then begin
            if VICScheduleGroupByRec.Type <> VICScheduleGroupBy::Blank then begin
                VICLevel2ScheduleGroupByToDisplay := VICScheduleGroupByRec.Type;
                VICScheduleGroupBys.Add(VICLevel2ScheduleGroupByToDisplay);
            end
        end;

        // Populate Activities from production schedule.
        Activities := VICJSONUtilities.CreateJsonArray();
        LoadGroupings(VICScheduleGroupBys, 2, Activities);

        // Load activities into control.
        CurrPage.conVSControlAddIn.AddActivities(Activities);

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




        ContextMenu := VICJSONUtilities.CreateJsonObject();
        ContextMenu.Add('ID', 'CM_Activities');

        ContextMenuItem := VICJSONUtilities.CreateJsonObject();
        ContextMenuItem.Add('Code', 'CODE1');
        ContextMenuItem.Add('Text', 'Text 1');
        TempContextMenuItems.Add(ContextMenuItem);

        ContextMenuItem := VICJSONUtilities.CreateJsonObject();
        ContextMenuItem.Add('Code', 'CODE2');
        ContextMenuItem.Add('Text', 'Text 2');
        TempContextMenuItems.Add(ContextMenuItem);

        ContextMenu.Add('Items', TempContextMenuItems);
        ContextMenus.Add(ContextMenu);

        CurrPage.conVSControlAddIn.AddContextMenus(ContextMenus);

        // Scroll to earliest activity.
        TempVICProductionSchedule.Reset();
        if not TempVICProductionScheduleFilter.IsEmpty then begin
            TempVICProductionSchedule.SetFilter(OrderNumber, TempVICProductionScheduleFilter.OrderNumber);
            TempVICProductionSchedule.SetFilter(FormulaId, TempVICProductionScheduleFilter.Formula);
        end;

        TempVICProductionSchedule.SetCurrentKey(StartDateTime);
        if TempVICProductionSchedule.FindFirst() then
            ScrollToActivity(TempVICProductionSchedule.ScheduleObjectId)
        else
            if FirstActivityId <> '' then
                ScrollToActivity(FirstActivityId);
    end;

    local procedure GetResourceTableText(TempVICResource: record VICResource temporary): Text
    var
    begin
        if TempVICResource.ResourceId <> '' then
            exit(TempVICResource.ResourceId)
        else
            exit('UNASSIGNED');
    end;

    local procedure GetResourceTooltipText(TempVICResource: record VICResource temporary; ResourceStartDate: DateTime; ResourceEndDate: DateTime): Text
    var
        TooltipText: Text;
        TableText: Text;
        Temp: Integer;
    begin
        if TempVICResource.ResourceType = VICScheduleGroupBy::PlanningAttribute then begin
            Temp := StrPos(TempVICResource.Description, '_');
            TooltipText := '<center><b>' + Text.DelStr(TempVICResource.Description, Temp) + '</b></center>';
        end
        else begin
            Temp := VICScheduleGroupBy.Ordinals().IndexOf(TempVICResource.ResourceType.AsInteger());
            TooltipText := '<center><b>' + VICScheduleGroupBy.Names().Get(Temp) + '</b></center>';
        end;

        TableText := GetResourceTableText(TempVICResource);

        TooltipText := TooltipText + '<table><tr><td>ID:</td><td>' + TableText + '</td></tr>';
        TooltipText := TooltipText + '<tr><td>Start Date:</td><td>' + Format(ResourceStartDate) + '</td></tr>';
        TooltipText := TooltipText + '<tr><td>End Date:</td><td>' + Format(ResourceEndDate) + '</td></tr></table>';

        exit(TooltipText);
    end;

    local procedure GetActivityTableText(TempVICProductionSchedule: Record VICProductionSchedule temporary): Text
    var
    begin
        exit(TempVICProductionSchedule.OrderNumber + ' [' + TempVICProductionSchedule.FormulaId + ']');
    end;

    local procedure GetActivityTooltipText(TempVICProductionSchedule: Record VICProductionSchedule temporary): Text
    var
        TooltipText: Text;
    begin
        if TempVICProductionSchedule.RecordType = VICVisualObjectType::BatchActivity
        then begin
            TooltipText := '<center><b>Batch</b></center>';
        end
        else begin
            TooltipText := '<center><b>Planned Order</b></center>';
        end;


        TooltipText := TooltipText + '<table><tr><td>Number:</td><td>' + TempVICProductionSchedule.OrderNumber + '</td></tr>' +
        '<tr><td>Facility ID:</td><td>' + TempVICProductionSchedule.FacilityId + '</td></tr>' +
        '<tr><td>Formula ID:</td><td> ' + TempVICProductionSchedule.FormulaId + '</td></tr>' +
        '<tr><td>Component ID:</td><td> ' + TempVICProductionSchedule.ComponentId + '</td></tr>' +
        '<tr><td>Start Date:</td><td> ' + FORMAT(TempVICProductionSchedule.StartDateTime) + '</td></tr>' +
        '<tr><td>End Date:</td><td> ' + FORMAT(TempVICProductionSchedule.EndDateTime) + '</td></tr></table>';
        exit(TooltipText);
    end;

    local procedure NewResourceActivity(ResourceStartDate: DateTime; ResourceEndDate: DateTime; ResourceId: Text; ParentId: Text; TempVICResource: record VICResource temporary): JsonObject
    var
        ResourceActivity: JsonObject;
        TooltipText: Text;
    begin
        ResourceActivity := VICJSONUtilities.CreateJsonObject();
        ResourceActivity.Add('Start', ResourceStartDate);
        ResourceActivity.Add('End', ResourceEndDate);



        ResourceActivity.Add('ResourceId', TempVICResource.ResourceId);
        ResourceActivity.Add('ResourceType', TempVICResource.ResourceType.AsInteger());



        TooltipText := GetResourceTooltipText(TempVICResource, ResourceStartDate, ResourceEndDate);
        ResourceActivity.Add('TooltipText', TooltipText);
        ResourceActivity.Add('BarSelectable', false);
        ResourceActivity.Add('RowSelectable', false);
        ResourceActivity.Add('BarSortMode', 1);
        ResourceActivity.Add('RowSortMode', 1);
        ResourceActivity.Add('ID', ResourceId);
        ResourceActivity.Add('ParentID', ParentId);
        ResourceActivity.Add('BarShape', 1);
        ResourceActivity.Add('TableText', GetResourceTableText(TempVICResource));
        ResourceActivity.Add('Color', 'pink');//  '#e69500');
        ResourceActivity.Add('BarText', 'RESOURCEID');
        ResourceActivity.Add('ContextMenuID', 'CM_Activities');
        ResourceActivity.Add('CollapseState', 0);
        ResourceActivity.Add('CustomText1', Format(VICVisualObjectType::SummaryActivity));
        ResourceActivity.Add('AllowedBarDragModes', VICScheduleDragMode::None.AsInteger());
        ResourceActivity.Add('AllowedRowDragModes', VICScheduleDragMode::None.AsInteger());
        exit(ResourceActivity);
    end;

    local procedure NewFormulaActivity(var TempVICFormula: Record VICFormula temporary; var UniqueIdCounter: Integer; var FormulaId: Text; ParentId: Text): JsonObject
    var
        VICJSONUtilities: Codeunit VICJSONUtilities;
        FormulaActivity: JsonObject;
    begin
        FormulaActivity := VICJSONUtilities.CreateJsonObject();


        UniqueIdCounter := UniqueIdCounter + 1;
        FormulaId := 'Act_Formula_' + Format(TempVICFormula.FormulaId) + Format(UniqueIdCounter);
        FormulaActivity.Add('ParentID', ParentId);
        FormulaActivity.Add('ID', FormulaId);
        FormulaActivity.Add('AddIn_TableText', 'F:' + Format(TempVICFormula.FormulaId));
        TempVICFormula.ScheduleObjectId := FormulaId;
        TempVICFormula.ScheduleResourceObjectId := ParentId;
        TempVICFormula.Modify();


        exit(FormulaActivity);
    end;

    local procedure LoadData()
    var
        VICProductionScheduleManagement: Codeunit VICProdScheduleManagement;
    begin
        UniqueIdCounter := 0;
        TempVICProductionSchedule.Reset();
        TempVICProductionSchedule.DeleteAll();
        VICProductionScheduleManagement.FetchVicinityScheduleFromWebApi(TempVICResource, TempVICProductionSchedule, TempVICFormula, TempVICComponent, ScheduleStartDate, ScheduleEndDate, UniqueIdCounter, Batches, FirmPlannedOrders, UnfirmedPlannedOrders); //, ManufacturingOrders, ManufacturingFormulas, ManufacturingComponents);

        // TempVICProductionSchedule.Reset();

        // TempVICProductionSchedule.SetFilter(OrderNumber, '0*');

        // if TempVICProductionSchedule.FindSet() then begin 
        //     Rec.DeleteAll();
        //     repeat
        //         Rec.Init();
        //     Rec.TransferFields(TempVICProductionSchedule);
        //     Rec.Insert();
        //     until TempVICProductionSchedule.Next() = 0;
        // end

    end;

    local procedure ProcessVerticalDragDrop(DroppedObjectId: Text; NewStartDate: DateTime; NewEndDate: DateTime): JsonArray
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        ReturnJsonArray: JsonArray;
        TableText: Text;
        TooltipText: Text;
        VICJSONUtilities: Codeunit VICJSONUtilities;
        SummaryStartDate: DateTime;
        SummaryEndDate: DateTime;
        ParentObjectId: Text;
        ObjectIdBeginSummarized: Text;
        Activity: JsonToken;
        ResourceId: Text;
        ResourceType: Enum VICScheduleGroupBy;
        ResourceInt: Integer;
    begin
        ReturnJsonArray := VICJSONUtilities.CreateJsonArray();
        JsonObject := VICJSONUtilities.CreateJsonObject();

        JsonObject.Add('ID', DroppedObjectId);
        JsonObject.Add('Start', NewStartDate);
        JsonObject.Add('End', NewEndDate);

        // Update production schedule.
        if TempVICProductionSchedule.Get(DroppedObjectId) then begin
            TempVICProductionSchedule.StartDateTime := NewStartDate;
            TempVICProductionSchedule.EndDateTime := NewEndDate;
            TempVICProductionSchedule.Modify();
            TableText := GetActivityTableText(TempVICProductionSchedule);
            JsonObject.Add('TableText', GetActivityTableText(TempVICProductionSchedule));
            JsonObject.Add('TooltipText', GetActivityTooltipText(TempVICProductionSchedule));
        end;
        ReturnJsonArray.Add(JsonObject);

        // Update summary
        SummaryStartDate := NewStartDate;
        SummaryEndDate := NewEndDate;

        // Get the parent resource of the dropped activity so we can update summary.
        repeat
        begin
            ParentObjectId := '';
            if Activities.SelectToken('$[?(@.ID==''' + DroppedObjectId + ''')]', JsonToken) then begin
                ParentObjectId := VICJsonUtilities.GetTextFromJson(JsonToken, 'ParentID');
                JsonToken.AsObject().Replace('Start', SummaryStartDate);
                JsonToken.AsObject().Replace('End', SummaryEndDate);
            end;
            if ParentObjectId <> '' then begin
                ObjectIdBeginSummarized := DroppedObjectId;
                DroppedObjectId := VICJsonUtilities.GetTextFromJson(JsonToken, 'ID');
                foreach Activity in Activities
                do begin
                    if (VICJsonUtilities.GetTextFromJson(Activity, 'ParentID') = ParentObjectId) and (VICJsonUtilities.GetTextFromJson(Activity, 'ID') <> ObjectIdBeginSummarized) then begin
                        if VICJsonUtilities.GetDateFromJson(Activity, 'Start') < SummaryStartDate then
                            SummaryStartDate := VICJsonUtilities.GetDateFromJson(Activity, 'Start');
                        if VICJsonUtilities.GetDateFromJson(Activity, 'End') > SummaryEndDate then
                            SummaryEndDate := VICJsonUtilities.GetDateFromJson(Activity, 'End');
                    end;
                end;
                JsonObject := VICJsonUtilities.CreateJsonObject();
                JsonObject.Add('ID', ParentObjectId);
                JsonObject.Add('Start', SummaryStartDate);
                JsonObject.Add('End', SummaryEndDate);
                ReturnJsonArray.Add(JsonObject);

                // Update resource's start date, end date, and tooltip in control activities array.
                if Activities.SelectToken('$[?(@.ID==''' + ParentObjectId + ''')]', JsonToken) then begin
                    JsonToken.AsObject().Replace('Start', SummaryStartDate);
                    JsonToken.AsObject().Replace('End', SummaryEndDate);
                    ResourceId := VICJsonUtilities.GetTextFromJson(JsonToken, 'ResourceId');
                    ResourceInt := VICJsonUtilities.GetIntegerFromJson(JsonToken, 'ResourceType');
                    ResourceType := Enum::VICScheduleGroupBy.FromInteger(ResourceInt);
                    if TempVICResource.Get(ResourceId, ResourceType) then begin
                        TooltipText := GetResourceTooltipText(TempVICResource, SummaryStartDate, SummaryEndDate);
                    end
                    else begin
                        TooltipText := 'NOTFOUND'
                    end;
                    JsonObject.Add('TooltipText', TooltipText);
                    JsonToken.AsObject().Replace('TooltipText', TooltipText);
                end;
            end;

            // Set object to process equal to the parent we just updated.
            DroppedObjectId := ParentObjectId;
        end
        until ParentObjectId = '';

        exit(ReturnJsonArray);


    end;
}