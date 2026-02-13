page 50334 "pte_vic_ItemStructure"
{
    Caption = 'Vicinity Item Structure';
    DataCaptionExpression = ItemStructurePageCaption();
    // DeleteAllowed = true;
    // InsertAllowed = true;
    // LinksAllowed = false;
    // ModifyAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SourceTable = pte_vic_ItemStructureHeader;
    SourceTableTemporary = true;
    SourceTableView = sorting(LineNo) order(ascending);
    ApplicationArea = All;

    // Caption = 'Vicinity Item Structure';
    // DeleteAllowed = false;
    // InsertAllowed = false;
    // LinksAllowed = false;
    // ModifyAllowed = false;
    // PageType = Worksheet;
    // SourceTableTemporary = true;
    // SourceTableView = sorting("Period Start", "Line No.")
    //                   order(ascending);

    layout
    {
        area(content)
        {
            group(Component)
            {
                Caption = 'Component';
                field(VicinityComponentId; Rec.ComponentId)
                {
                    ApplicationArea = All;
                    Caption = 'Component ID';
                    Editable = false;
                    // ToolTip = 'Specifies the unique identifier of the component.';
                }
                field(VicinityComponentDescription; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Component Name';
                    Editable = false;
                    // ToolTip = 'Specifies the name of the component.';
                }
                field(DefaultFacilityId; Rec.DefaultFacilityId)
                {
                    ApplicationArea = All;
                    Caption = 'Default Facility ID';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(StockingUnitOfMeasure; Rec.UnitOfMeasure)
                {
                    ApplicationArea = All;
                    Caption = 'Stocking Unit of Measure';
                    Editable = false;
                    // ToolTip = 'Specifies the unit of measure in which the item is stocked. This is informational only.';
                }
            }
            group(Facility)
            {
                Caption = 'Facility';
                field(AssignedToFacility; LocalAssignedToFacility)
                {
                    ApplicationArea = All;
                    Caption = 'Assigned To Facility';
                    Editable = false;
                }

                field(FacilityId; SelectedFacilityId)
                {
                    ApplicationArea = All;
                    Caption = 'Facility ID';
                    TableRelation = VICFacility.FacilityId;

                    trigger OnValidate()
                    begin
                        if SelectedFacilityId = '' then
                            Error('Facility ID cannot be empty.')
                        else begin
                            // Validate that FacilityId exists in VICFacilityTemp
                            if not VICFacilityTemp.Get(SelectedFacilityId) then
                                Error('Facility ID %1 does not exist.', SelectedFacilityId);
                        end;
                        if TempVICComponentLocation.Get(Rec.ComponentId, SelectedFacilityId) then begin
                            LocalAssignedToFacility := true;
                            // Rec.FacilityId := TempVICComponentLocation.LocationId;
                            SelectedFacilityId := TempVICComponentLocation.LocationId;
                            FormulaId := TempVICComponentLocation.FormulaId;
                            FillQuantityPerStockingUnit := TempVICComponentLocation.FillQuantityPerStockingUnit;
                            FillQuantityUnitOfMeasure := TempVICComponentLocation.FillQuantityUnitOfMeasure;
                            FormulaSourceType := TempVICComponentLocation.FormulaSourceType;
                            MachineId := TempVICComponentLocation.MachineId;
                            MachineCapacity := TempVICComponentLocation.MachineCapacity;
                            MachineCapacityUnitOfMeasure := TempVICComponentLocation.MachineCapacityUnitOfMeasure;

                            // CurrPage.ItemStructureLine.Page.ParseComponentBOM(JsonComponentObj.GetArray('ComponentBOM'), TempVICComponent.ComponentId, LineNo, SelectedFacilityId);

                            CurrPage.ItemStructureLine.Page.LoadComponentBOM(TempVICItemStructureLine, SelectedFacilityId);
                            CurrPage.Update();


                        end
                        else begin
                            LocalAssignedToFacility := false;
                            SelectedFacilityId := '';
                            // Rec.FacilityId := '';
                            FormulaId := 'NOT ASSIGNED';
                            FillQuantityPerStockingUnit := 0;
                            FillQuantityUnitOfMeasure := '';
                            FormulaSourceType := FormulaSourceType::Mix;
                            MachineId := '';
                            MachineCapacity := 0;
                            MachineCapacityUnitOfMeasure := '';
                        end;
                    end;
                }
                field(FormulaId; FormulaId)
                {
                    ApplicationArea = All;
                    Caption = 'Formula ID';
                    Editable = LocalAssignedToFacility;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempBuf: Record "VICFormulaLookup" temporary;
                        LookupPage: Page "VICFormulaLookup";
                    begin
                        // FillComponents(TempBuf);

                        TempBuf.Reset();
                        TempBuf.DeleteAll();

                        TempBuf.Init();
                        TempBuf."Code" := 'CK-FG01';
                        TempBuf."Description" := 'Finished Good 01';
                        TempBuf.Insert();

                        TempBuf.Init();
                        TempBuf."Code" := 'CK-PK01';
                        TempBuf."Description" := 'Packaging 01';
                        TempBuf.Insert();

                        if Page.RunModal(Page::"VICFormulaLookup", TempBuf) = Action::LookupOK then begin
                            Text := TempBuf."Code";

                            // LookupPage.SetTableView(TempBuf);
                            // LookupPage.LookupMode(true);

                            // if LookupPage.RunModal() = Action::LookupOK then begin

                            LookupPage.GetRecord(TempBuf);
                            FormulaId := TempBuf."Code";
                            exit(true);
                        end;

                        exit(false);
                    end;
                }
                field(FillQuantityPerStockingUnit; FillQuantityPerStockingUnit)
                {
                    ApplicationArea = All;
                    Caption = 'Fill Quantity Per Stocking Unit';
                    Editable = LocalAssignedToFacility;
                }
                field(FillQuantityUnitOfMeasure; FillQuantityUnitOfMeasure)
                {
                    ApplicationArea = All;
                    Caption = 'Fill Quantity Unit Of Measure';
                    Editable = false;
                }
                field(FormulaSourceType; FormulaSourceType)
                {
                    ApplicationArea = All;
                    Caption = 'Formula Source Type';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineId; MachineId)
                {
                    ApplicationArea = All;
                    Caption = 'Machine ID';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineCapacity; MachineCapacity)
                {
                    ApplicationArea = All;
                    Caption = 'Machine Capacity';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineCapacityUnitOfMeasure; MachineCapacityUnitOfMeasure)
                {
                    ApplicationArea = All;
                    Caption = 'Machine Capacity Unit Of Measure';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
            }
            part(ItemStructureLine; "VicItemStructureLine")
            {
                ApplicationArea = All;
                SubPageLink = ComponentId = field("ComponentId"); //, FacilityId = field("FacilityId");
            }

            // repeater(Control1)
            // {
            //     Editable = false;
            //     IndentationColumn = Rec.Level;
            //     IndentationControls = Description;
            //     ShowAsTree = true;
            //     TreeInitialState = ExpandAll;
            //     ShowCaption = false;
            //     field(Type; Rec.LineType)
            //     {
            //         Caption = 'Type';
            //         ApplicationArea = Basic, Suite;
            //         Editable = false;
            //         Style = Strong;
            //         StyleExpr = Emphasize;
            //         // ToolTip = 'Specifies the transaction date of the availability line. Batch procedure (ingredients, by/co products) and BOM plan start; batch end item end date; planned order due date; PO expected receipt date; and SO required date.';
            //         Visible = true;

            //         // trigger OnDrillDown()
            //         // begin
            //         //     ShowDocument();
            //         // end;
            //     }
            //     field(Id; Rec.Id)
            //     {
            //         Caption = 'ID';
            //         ApplicationArea = Basic, Suite;
            //         Editable = false;
            //         Style = Strong;
            //         StyleExpr = Emphasize;
            //         // ToolTip = 'Specifies the description of the availability line.';
            //         // trigger OnDrillDown()
            //         // begin
            //         //     ShowDocument();
            //         // end;
            //     }
            //     field(Description; Rec.Description)
            //     {
            //         Caption = 'Description';
            //         ApplicationArea = Basic, Suite;
            //         Editable = false;
            //         Style = Strong;
            //         StyleExpr = Emphasize;
            //         // ToolTip = 'Specifies the description of the availability line.';
            //     }
            //     field(Quantity; Rec.Quantity)
            //     {
            //         Caption = 'Quantity';
            //         ApplicationArea = Basic, Suite;
            //         Editable = false;
            //         // ToolTip = 'Specifies the quantity of the availability line.';    
            //     }
            // }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(DrillToVicinityFormulaRef; DrillToFormulaDetail)
            {
            }
        }

        area(Processing)
        {
            action(DrillToFormulaDetail)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vicinity Formula';
                ToolTip = 'Drill to Formula Details';
                Image = Action;

                trigger OnAction()
                var
                    DrillDown: Text;
                begin
                    DrillDown := VICDrillbackUrl + '/?ProductId=FormulaEntry';
                    if FormulaId <> '' then
                        DrillDown := DrillDown + '&FormulaId=' + FormulaId;
                    Hyperlink((DrillDown));
                end;
            }
        }
    }

    var
        TempItem: Record Item temporary;
        TempVICComponent: Record VICComponent temporary;
        TempVICComponentLocation: Record VICComponentLocation temporary;
        TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary;
        //        JsonVICComponentObject: JsonObject;
        JsonComponentObj: JsonObject;
        VICItemStructureMgmt: Codeunit VICItemStructureMgmt;



        VICJSONUtilities: Codeunit VICJSONUtilities;
        VICWebServiceInterface: Codeunit VICWebApiInterface;
        VICFacilityTemp: Record VICFacilityTemp temporary;
        VICDrillbackUrl: Text[200];
        SelectedFacilityId: Code[15];









        // DefaultFacilityId: Code[15];

        LocalAssignedToFacility: Boolean;
        FormulaId: Code[32];
        FillQuantityPerStockingUnit: Decimal;
        FillQuantityUnitOfMeasure: Text[20];
        FormulaSourceType: Enum FormulaSourceType;
        MachineId: Text[20];
        MachineCapacity: Decimal;
        MachineCapacityUnitOfMeasure: Code[10];
        Emphasize: Boolean;

        LocationFilter: Text;
        VariantFilter: Text;
        PeriodType: Option Day,Week,Month,Quarter,Year;


    procedure SetItem(var NewItem: Record Item)
    begin
        TempItem.Copy(NewItem);
        //        UpdateItemRequestFields(Item);
    end;

    local procedure ItemStructurePageCaption(): Text[250]
    begin
        exit(StrSubstNo('%1 %2', TempItem."No.", TempItem.Description));
    end;

    trigger OnAfterGetRecord()
    begin
        Emphasize := EmphasizeLine;
        //        CurrPage.Update();
        // if rec.VicinityEntityType = 0 then
        //     EnableShowDocumentAction := false
        // else
        //     EnableShowDocumentAction := true;
    end;

    trigger OnOpenPage()
    var
        VICSetup: Record "Vicinity Setup";
        IsHandled: Boolean;
        LineNo: Integer;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        // Load Vicinity Setup
        if VICSetup.Get() then
            VICDrillbackUrl := VICSetup.VicinityDrillbackUrl;

        //        VICWebServiceInterface.OnFetchVICComponent(TempItem."No.", IsHandled, JsonVICComponentObject);

        // Fetch component data from web API.
        VICWebServiceInterface.OnFetchVICComponent(TempItem."No.", IsHandled, JObject);

        // Make sure it is a valid Vicinity component JSON object.
        if JObject.Get('Component', JToken) then begin
            if JToken.IsObject() then
                JsonComponentObj := JToken.AsObject()
            else begin
                if JToken.AsValue().IsNull() then begin
                    Message('No component data found for Item %1 in Vicinity.', TempItem."No.");
                    exit
                end;
            end;
        end
        else begin
            Message('No component data found for Item %1 in Vicinity.', TempItem."No.");
            exit;
        end;

        // Parse component data and populate temporary tables.
        VICItemStructureMgmt.ParseJsonComponentIntoTables(JsonComponentObj, Rec, TempVICComponentLocation, TempVICItemStructureLine);








        // Parse into temporary tables.
        //        ParseComponent(JsonComponentObj, TempVICComponent);       
        //        ParseComponentHeader(JsonComponentObj, Rec);
        // ParseLocations(JsonComponentObj.GetArray('ComponentLocations'), TempVICComponentLocation);

        //        TempVICComponent.Get(TempItem."No.");
        //        DefaultFacilityId := TempVICComponent.DefaultFacilityId;

        if TempVICComponentLocation.Get(Rec.ComponentId, Rec.DefaultFacilityId) then begin
            LocalAssignedToFacility := true;



            // Rec.FacilityId := TempVICComponentLocation.LocationId;

            SelectedFacilityId := TempVICComponentLocation.LocationId;

            FormulaId := TempVICComponentLocation.FormulaId;
            FillQuantityPerStockingUnit := TempVICComponentLocation.FillQuantityPerStockingUnit;
            FillQuantityUnitOfMeasure := TempVICComponentLocation.FillQuantityUnitOfMeasure;
            FormulaSourceType := TempVICComponentLocation.FormulaSourceType;
            MachineId := TempVICComponentLocation.MachineId;
            MachineCapacity := TempVICComponentLocation.MachineCapacity;
            MachineCapacityUnitOfMeasure := TempVICComponentLocation.MachineCapacityUnitOfMeasure;
        end
        else begin
            LocalAssignedToFacility := false;
            // Rec.FacilityId := '';

            SelectedFacilityId := ''; //DefaultFacilityId;

            FormulaId := 'NOT ASSIGNED';
            FillQuantityPerStockingUnit := 0;
            FillQuantityUnitOfMeasure := '';
            FormulaSourceType := FormulaSourceType::Mix;
            MachineId := '';
            MachineCapacity := 0;
            MachineCapacityUnitOfMeasure := '';
        end;

        LineNo := 0;
        Rec.Reset();
        Rec.DeleteAll();
        // ParseComponentLabor(ComponentObj.GetArray('ComponentLabor'), Rec, LineNo, DefaultFacilityId);
        // ParseComponentBOM(ComponentObj.GetArray('ComponentBOM'), Rec, LineNo, DefaultFacilityId);

        // ParseComponentLabor(GetArray(ComponentObj, 'ComponentLabor', IdIndex), IdIndex, Rec, LineNo, DefaultFacilityId);
        // ParseComponentBOM(GetArray(ComponentObj, 'ComponentBOM', IdIndex), IdIndex, Rec, LineNo, DefaultFacilityId);

        VICWebServiceInterface.OnFetchTempVICFacilities(VICFacilityTemp);

        // VICFacilityTemp.Reset();
        // VICFacilityTemp.SetCurrentKey(FacilityId);
        // if VICFacilityTemp.FindSet() then
        //     repeat
        //         Message('Temp Facility ID: %1, Name: %2', VICFacilityTemp.FacilityId, VICFacilityTemp.Name);
        //     until VICFacilityTemp.Next() = 0;



        // TempVICItemStructureLine.Reset();
        // TempVICItemStructureLine.DeleteAll();
        // ParseComponentBOM(ComponentObj.GetArray('ComponentBOM'), VICComponent.ComponentId, LineNo, DefaultFacilityId);

        // CurrPage.ItemStructureLine.PAGE.SetItemStructureLine(VICItemStructureLine);

        //        CurrPage.ItemStructureLine.Page.ParseComponentBOM(JsonComponentObj.GetArray('ComponentBOM'), TempVICComponent.ComponentId, LineNo, Rec.DefaultFacilityId);

        CurrPage.ItemStructureLine.Page.LoadComponentBOM(TempVICItemStructureLine, SelectedFacilityId);

        CurrPage.Update();

        //        CurrPage.ItemStructureLine.PAGE.LoadData(VICItemStructureLine); 
    end;

    local procedure ParseComponent(ComponentObj: JsonObject; var TempComponent: Record VICComponent temporary)
    var
        ComponentId: Text[32];
        DummyIndex: Dictionary of [Text, Text];
    begin
        ComponentId := ComponentObj.GetText('ComponentId'); // CopyStr(VICJSONUtilities.GetText(ComponentObj, 'ComponentId', DummyIndex), 1, MaxStrLen(TempComponent.ComponentId));
        if ComponentId = '' then
            exit;
        if TempComponent.Get(ComponentId) then
            exit;
        TempComponent.Init();
        TempComponent.ComponentId := ComponentId;
        TempComponent.Description := ComponentObj.GetText('Description'); // CopyStr(VICJSONUtilities.GetText(ComponentObj, 'Description', DummyIndex), 1, MaxStrLen(TempComponent.Description));
        TempComponent.DefaultFacilityId := ComponentObj.GetText('DefaultFacilityId'); // CopyStr(VICJSONUtilities.GetText(ComponentObj, 'DefaultFacilityId', DummyIndex), 1, MaxStrLen(TempComponent.DefaultFacilityId));
        TempComponent.Insert();
    end;

    local procedure ParseComponentHeader(ComponentObj: JsonObject; var TempVICItemStructureHeader: Record pte_vic_ItemStructureHeader temporary)
    var
        ComponentId: Text[32];
        DummyIndex: Dictionary of [Text, Text];
    begin
        ComponentId := ComponentObj.GetText('ComponentId'); // CopyStr(VICJSONUtilities.GetText(ComponentObj, 'ComponentId', DummyIndex), 1, MaxStrLen(TempComponent.ComponentId));
        if ComponentId = '' then
            exit;
        if TempVICItemStructureHeader.Get(ComponentId) then
            exit;
        TempVICItemStructureHeader.Init();
        TempVICItemStructureHeader.ComponentId := ComponentId;
        TempVICItemStructureHeader.Description := ComponentObj.GetText('Description');
        TempVICItemStructureHeader.DefaultFacilityId := ComponentObj.GetText('DefaultFacilityId');
        TempVICItemStructureHeader.Insert();
    end;


    local procedure ParseLocations(LocArr: JsonArray; var TempLocation: Record VICComponentLocation temporary)
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
    begin
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            TempLocation.Init();
            TempLocation.ComponentId := Obj.GetText('ComponentId');
            TempLocation.LocationId := Obj.GetText('LocationId');
            TempLocation.FormulaId := Obj.GetText('FormulaId');
            TempLocation.FillQuantityPerStockingUnit := Obj.GetDecimal('Quantity');
            TempLocation.FillQuantityUnitOfMeasure := Obj.GetText('UnitId');
            TempLocation.MachineId := Obj.GetText('MachineId');
            TempLocation.MachineCapacity := Obj.GetDecimal('MachineCapacity');
            TempLocation.MachineCapacityUnitOfMeasure := Obj.GetText('MachineCapacityUnitId');
            if Obj.GetInteger('FormulaSource') = 0 then
                TempLocation.FormulaSourceType := TempLocation.FormulaSourceType::Mix
            else
                TempLocation.FormulaSourceType := TempLocation.FormulaSourceType::Fill;
            if TempLocation.ComponentId <> '' then begin
                if TempLocation.Get(TempLocation.ComponentId, TempLocation.LocationId) then
                    TempLocation.Modify()
                else
                    TempLocation.Insert();
            end;
        end;
    end;

    local procedure ParseComponentLabor(LocArr: JsonArray; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary; var LineNo: Integer; FacilityId: Text[15])
    var
        Tok: JsonToken;
        Obj: JsonObject;
        LocationId: Text[15];
    begin
        LineNo += 1;
        TempVICItemStructureLine.Init();
        TempVICItemStructureLine.LineNo := LineNo;
        TempVICItemStructureLine.Level := 0;
        TempVICItemStructureLine.Description := 'Routing';
        TempVICItemStructureLine.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LocationId := Obj.GetText('LocationId');
            if LocationId = FacilityId then begin
                LineNo += 1;
                TempVICItemStructureLine.Init();
                TempVICItemStructureLine.LineNo := LineNo;
                TempVICItemStructureLine.Level := 1;
                if Obj.GetInteger('LineType') = 2 then
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Setup
                else
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Runtime;
                TempVICItemStructureLine.Id := Obj.GetText('LaborId'); //
                TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
                TempVICItemStructureLine.FacilityId := Obj.GetText('LocationId');
                TempVICItemStructureLine.Description := Obj.GetText('Description', true);
                TempVICItemStructureLine.Quantity := Obj.GetDecimal('LaborTime');
                TempVICItemStructureLine.Insert();
            end;
        end;
    end;

    // local procedure ParseComponentLabor(LocArr: JsonArray; var IdIndex: Dictionary of [Text, Text]; var TempVICItemStructurePageData: Record VICItemStructurePageData temporary; var LineNo: Integer; FacilityId: Text[15])
    // var
    //     i: Integer;
    //     Tok: JsonToken;
    //     Obj: JsonObject;

    // begin
    //     LineNo += 1;
    //     TempVICItemStructurePageData.Init();
    //     TempVICItemStructurePageData.LineNo := LineNo;
    //     TempVICItemStructurePageData.Level := 0;
    //     TempVICItemStructurePageData.Description := 'Routing';
    //     TempVICItemStructurePageData.Insert();
    //     for i := 0 to LocArr.Count() - 1 do begin
    //         LocArr.Get(i, Tok);
    //         Obj := ResolveToObject(Tok, IdIndex);
    //         LineNo += 1;
    //         if CopyStr(VICJSONUtilities.GetText(Obj, 'LocationId', IdIndex), 1, MaxStrLen(TempVICItemStructurePageData.FacilityId)) = FacilityId then begin
    //             TempVICItemStructurePageData.Init();
    //             TempVICItemStructurePageData.LineNo := LineNo;
    //             TempVICItemStructurePageData.Level := 1;
    //             if VICJSONUtilities.GetInt(Obj, 'LineType', IdIndex) = 2 then
    //                 TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Setup
    //             else
    //                 TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Runtime;
    //             TempVICItemStructurePageData.Id := CopyStr(VICJSONUtilities.GetText(Obj, 'LaborId', IdIndex), 1, MaxStrLen(TempVICItemStructurePageData.Id));
    //             TempVICItemStructurePageData.ComponentId := CopyStr(VICJSONUtilities.GetText(Obj, 'ComponentId', IdIndex), 1, MaxStrLen(TempVICItemStructurePageData.ComponentId));
    //             TempVICItemStructurePageData.FacilityId := CopyStr(VICJSONUtilities.GetText(Obj, 'LocationId', IdIndex), 1, MaxStrLen(TempVICItemStructurePageData.FacilityId));
    //             TempVICItemStructurePageData.Description := CopyStr(VICJSONUtilities.GetText(Obj, 'Description', IdIndex), 1, MaxStrLen(TempVICItemStructurePageData.Description));
    //             TempVICItemStructurePageData.Quantity := VICJSONUtilities.GetDecimal(Obj, 'LaborTime', IdIndex);
    //             TempVICItemStructurePageData.Insert();
    //         end;
    //     end;
    // end;

    procedure ParseComponentBOM(LocArr: JsonArray; ComponentId: Text[20]; LineNo: Integer; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
    begin
        LineNo += 1;
        // Rec.Init();
        // Rec.LineNo := LineNo;
        // Rec.ComponentId := ComponentId;
        // Rec.FacilityId := FacilityId;
        // Rec.Level := 0;
        // Rec.Description := 'Bill of Materials';
        // Rec.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LineNo += 1;
            if Obj.GetText('LocationId') = FacilityId then begin
                TempVICItemStructureLine.Init();
                TempVICItemStructureLine.LineNo := LineNo;
                TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
                TempVICItemStructureLine.FacilityId := Obj.GetText('LocationId');
                TempVICItemStructureLine.Level := 0;
                if Obj.GetInteger('LineType') = TempVICItemStructureLine.LineType::Component.AsInteger() then begin
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Component;
                    TempVICItemStructureLine.Id := Obj.GetText('SubComponentId');
                    if Item.Get(TempVICItemStructureLine.Id) then begin
                        TempVICItemStructureLine.Description := Item.Description;
                        if Obj.GetInteger('BOMQuantityType') + 1 = TempVICItemStructureLine.QtyType::PerParent.AsInteger() then
                            TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::PerParent
                        else
                            TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::OfParent;
                        TempVICItemStructureLine.Quantity := Obj.GetDecimal('BOMQuantity');
                    end
                    else begin
                        TempVICItemStructureLine.Description := 'NOT FOUND';
                    end
                end
                else begin
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Instruction;
                    TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::Blank;
                    TempVICItemStructureLine.Instruction := PadStr(Obj.GetText('Instruction', true), MaxStrLen(TempVICItemStructureLine.Instruction));
                end;
                TempVICItemStructureLine.Insert();
            end;
        end;
    end;

    local procedure ParseComponentBOM(LocArr: JsonArray; var TempVICItemStructurePageData: Record pte_vic_ItemStructureHeader temporary; ComponentId: Text[20]; LineNo: Integer; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;

    begin
        LineNo += 1;
        TempVICItemStructurePageData.Init();
        TempVICItemStructurePageData.ComponentId := ComponentId;
        TempVICItemStructurePageData.LineNo := LineNo;
        TempVICItemStructurePageData.FacilityId := FacilityId;
        TempVICItemStructurePageData.Level := 0;
        TempVICItemStructurePageData.Description := 'Bill of Materials';
        TempVICItemStructurePageData.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LineNo += 1;
            if Obj.GetText('LocationId') = FacilityId then begin
                TempVICItemStructurePageData.Init();
                TempVICItemStructurePageData.ComponentId := ComponentId;
                TempVICItemStructurePageData.LineNo := LineNo;
                TempVICItemStructurePageData.FacilityId := FacilityId;
                TempVICItemStructurePageData.Level := 1;
                if Obj.GetInteger('LineType') = 1 then
                    TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Component
                else
                    TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Instruction;
                TempVICItemStructurePageData.ComponentId := Obj.GetText('ComponentId');
                TempVICItemStructurePageData.FacilityId := Obj.GetText('LocationId');
                if TempVICItemStructurePageData.LineType = TempVICItemStructurePageData.LineType::Component then begin
                    TempVICItemStructurePageData.Id := Obj.GetText('SubComponentId');
                    TempVICItemStructurePageData.Description := Obj.GetText('Description', true);
                    TempVICItemStructurePageData.Quantity := Obj.GetDecimal('QuantityInStockUOM');
                end;
                TempVICItemStructurePageData.Insert();
            end;
        end;
    end;

    local procedure EmphasizeLine(): Boolean
    begin
        exit(Rec.Level = 0);
    end;
}

page 50336 "VicItemStructureLine"
{
    Caption = 'BOM and Additional Costs';
    PageType = ListPart;
    SourceTable = pte_vic_ItemStructureLine;
    SourceTableTemporary = true; // Crucial
    InsertAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Editable = true;
                // IndentationColumn = Rec.Level;
                //  IndentationControls = Description;
                //  ShowAsTree = false;
                // TreeInitialState = ExpandAll;
                ShowCaption = false;
                field(ComponentId; Rec.ComponentId)
                {
                    Caption = 'Component ID';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(FacilityId; Rec.FacilityId)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(LineNo; Rec.LineNo)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Type; Rec.LineType)
                {
                    Caption = 'Type';
                    ApplicationArea = All;
                    Editable = true;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    // ToolTip = 'Specifies the transaction date of the availability line. Batch procedure (ingredients, by/co products) and BOM plan start; batch end item end date; planned order due date; PO expected receipt date; and SO required date.';
                    Visible = true;


                    // trigger OnDrillDown()
                    // begin
                    //     ShowDocument();
                    // end;
                }
                field(Id; Rec.Id)
                {
                    Caption = 'ID';
                    ApplicationArea = All;
                    Editable = true;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    // ToolTip = 'Specifies the description of the availability line.';
                    // trigger OnDrillDown()
                    // begin
                    //     ShowDocument();
                    // end;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                    Editable = true;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    // ToolTip = 'Specifies the description of the availability line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;
                    Editable = true;
                    // ToolTip = 'Specifies the quantity of the availability line.';
                }
                field(QuantityType; Rec.QtyType)
                {
                    Caption = 'Quantity type';
                    ApplicationArea = All;
                    Editable = true;
                    // ToolTip = 'Specifies the quantity of the availability line.';
                }
                field(Instruction; Rec.Instruction)
                {
                    Caption = 'Instruction';
                    ApplicationArea = All;
                    Editable = true;
                    // ToolTip = 'Specifies the quantity of the availability line.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // group("&Operation")
            // {
            //      Caption = '&Operation';
            //      Image = Task;
            action("&Instruction")
            {
                Caption = 'Instruction';
                Image = ViewComments;
                ToolTip = 'View instructions.';
                Enabled = Rec.LineType = Rec.LineType::Instruction;
                ApplicationArea = All;
                // Enabled = ShowRelatedDataEnabled;

                trigger OnAction()
                begin
                    Message('Instruction: %1', Rec.Instruction);
                end;
            }
            // }
        }
    }

    var
        Emphasize: Boolean;

    // procedure SetItemStructureLine(var NewRec: Record VICItemStructureLine temporary)
    // begin
    //     Rec := NewRec;
    // end;

    procedure LoadComponentBOM(var VICItemStructureLine: Record pte_vic_ItemStructureLine temporary; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        VICItemStructureLine.Reset();
        VICItemStructureLine.SetRange(FacilityId, FacilityId);
        if VICItemStructureLine.FindSet() then begin
            repeat
                Rec.Init();
                Rec.LineNo := VICItemStructureLine.LineNo;
                Rec.ComponentId := VICItemStructureLine.ComponentId;
                Rec.FacilityId := VICItemStructureLine.FacilityId;
                Rec.Level := 0;
                if VICItemStructureLine.LineType = Rec.LineType::Component then begin
                    Rec.LineType := Rec.LineType::Component;
                    Rec.Id := VICItemStructureLine.Id;
                    if Item.Get(Rec.Id) then begin
                        Rec.Description := Item.Description;
                        Rec.QtyType := VICItemStructureLine.QtyType;
                        Rec.Quantity := VICItemStructureLine.Quantity;
                    end
                    else begin
                        Rec.Description := 'NOT FOUND';
                    end
                end
                else if VICItemStructureLine.LineType = Rec.LineType::Instruction then begin
                    Rec.LineType := Rec.LineType::Instruction;
                    Rec.QtyType := Rec.QtyType::Blank;
                    Rec.Instruction := VICItemStructureLine.Instruction;
                end
                else begin
                    Rec.LineType := VICItemStructureLine.LineType;
                    Rec.Id := VICItemStructureLine.Id;
                    Rec.Quantity := VICItemStructureLine.Quantity;
                    if Rec.LineType = Rec.LineType::Setup then
                        Rec.QtyType := VICItemStructureLine.QtyType::Time
                    else
                        Rec.QtyType := VICItemStructureLine.QtyType::TimePerParent;
                end;
                Rec.Insert();
            until VICItemStructureLine.Next() = 0;
        end;
    end;

    procedure ParseComponentBOM(LocArr: JsonArray; ComponentId: Text[20]; LineNo: Integer; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        LineNo += 1;
        // Rec.Init();
        // Rec.LineNo := LineNo;
        // Rec.ComponentId := ComponentId;
        // Rec.FacilityId := FacilityId;
        // Rec.Level := 0;
        // Rec.Description := 'Bill of Materials';
        // Rec.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LineNo += 1;
            if Obj.GetText('LocationId') = FacilityId then begin
                Rec.Init();
                Rec.LineNo := LineNo;
                Rec.ComponentId := Obj.GetText('ComponentId');
                Rec.FacilityId := Obj.GetText('LocationId');
                Rec.Level := 0;
                if Obj.GetInteger('LineType') = Rec.LineType::Component.AsInteger() then begin
                    Rec.LineType := Rec.LineType::Component;
                    Rec.Id := Obj.GetText('SubComponentId');
                    if Item.Get(Rec.Id) then begin
                        Rec.Description := Item.Description;
                        if Obj.GetInteger('BOMQuantityType') + 1 = Rec.QtyType::PerParent.AsInteger() then
                            Rec.QtyType := Rec.QtyType::PerParent
                        else
                            Rec.QtyType := Rec.QtyType::OfParent;
                        Rec.Quantity := Obj.GetDecimal('BOMQuantity');
                    end
                    else begin
                        Rec.Description := 'NOT FOUND';
                    end
                end
                else begin
                    Rec.LineType := Rec.LineType::Instruction;
                    Rec.QtyType := Rec.QtyType::Blank;
                    Rec.Instruction := PadStr(Obj.GetText('Instruction', true), MaxStrLen(Rec.Instruction));
                end;
                Rec.Insert();
            end;
        end;
    end;

    procedure ParseComponentLabor(LocArr: JsonArray; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary; var LineNo: Integer; FacilityId: Text[15])
    var
        Tok: JsonToken;
        Obj: JsonObject;
        LocationId: Text[15];
    begin
        LineNo += 1;
        TempVICItemStructureLine.Init();
        TempVICItemStructureLine.LineNo := LineNo;
        TempVICItemStructureLine.Level := 0;
        TempVICItemStructureLine.Description := 'Routing';
        TempVICItemStructureLine.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LocationId := Obj.GetText('LocationId');
            if LocationId = FacilityId then begin
                LineNo += 1;
                TempVICItemStructureLine.Init();
                TempVICItemStructureLine.LineNo := LineNo;
                TempVICItemStructureLine.Level := 1;
                if Obj.GetInteger('LineType') = 2 then
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Setup
                else
                    TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Runtime;
                TempVICItemStructureLine.Id := Obj.GetText('LaborId'); //
                TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
                TempVICItemStructureLine.FacilityId := Obj.GetText('LocationId');
                TempVICItemStructureLine.Description := Obj.GetText('Description', true);
                TempVICItemStructureLine.Quantity := Obj.GetDecimal('LaborTime');
                TempVICItemStructureLine.Insert();
            end;
        end;
    end;

    // Procedure to fill the temp table
    procedure LoadData(var TempVicItemStructureLine: Record pte_vic_ItemStructureLine temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();

        // Dummy Data
        Rec.LineType := Rec.LineType::Component;
        Rec.Id := 'COMP1';
        Rec.Description := 'Component 1 Description';
        Rec.Insert();
    end;

    trigger OnAfterGetRecord()
    begin
        // Emphasize := EmphasizeLine;
        // if rec.VicinityEntityType = 0 then
        //     EnableShowDocumentAction := false
        // else
        //     EnableShowDocumentAction := true;
    end;

    local procedure EmphasizeLine(): Boolean
    begin
        exit(Rec.Level = 0);
    end;
}


codeunit 50334 "VICItemStructureMgmt"
{
    procedure ParseJsonComponentIntoTables(JsonComponentObj: JsonObject; var TempVICItemStructureHeader: Record pte_vic_ItemStructureHeader temporary; var TempVICComponentLocation: Record VICComponentLocation temporary; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary)
    var
        ComponentId: Text[32];
        DummyIndex: Dictionary of [Text, Text];
    begin
        ComponentId := JsonComponentObj.GetText('ComponentId');
        if ComponentId = '' then
            exit;
        if TempVICItemStructureHeader.Get(ComponentId) then
            exit;
        TempVICItemStructureHeader.Init();
        TempVICItemStructureHeader.ComponentId := ComponentId;
        TempVICItemStructureHeader.Description := JsonComponentObj.GetText('Description');
        TempVICItemStructureHeader.DefaultFacilityId := JsonComponentObj.GetText('DefaultFacilityId');
        TempVICItemStructureHeader.UnitOfMeasure := JsonComponentObj.GetText('StockingUnitId');
        TempVICItemStructureHeader.Insert();

        ParseLocations(JsonComponentObj.GetArray('ComponentLocations'), TempVICComponentLocation);
        ParseComponentAdditionalCostsAndBOM(JsonComponentObj, TempVICComponentLocation, TempVICItemStructureLine);
    end;

    local procedure ParseLocations(LocArr: JsonArray; var TempLocation: Record VICComponentLocation temporary)
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
    begin
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            TempLocation.Init();
            TempLocation.ComponentId := Obj.GetText('ComponentId');
            TempLocation.LocationId := Obj.GetText('LocationId');
            TempLocation.FormulaId := Obj.GetText('FormulaId');
            TempLocation.FillQuantityPerStockingUnit := Obj.GetDecimal('Quantity');
            TempLocation.FillQuantityUnitOfMeasure := Obj.GetText('UnitId');
            TempLocation.MachineId := Obj.GetText('MachineId');
            TempLocation.MachineCapacity := Obj.GetDecimal('MachineCapacity');
            TempLocation.MachineCapacityUnitOfMeasure := Obj.GetText('MachineCapacityUnitId');
            if Obj.GetInteger('FormulaSource') = 0 then
                TempLocation.FormulaSourceType := TempLocation.FormulaSourceType::Mix
            else
                TempLocation.FormulaSourceType := TempLocation.FormulaSourceType::Fill;
            if TempLocation.ComponentId <> '' then begin
                if TempLocation.Get(TempLocation.ComponentId, TempLocation.LocationId) then
                    TempLocation.Modify()
                else
                    TempLocation.Insert();
            end;
        end;
    end;

    procedure ParseComponentAdditionalCostsAndBOM(JsonComponentObj: JsonObject; var TempVICComponentLocation: Record VICComponentLocation temporary; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary)
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
        LineNo: Integer;
        JsonComponentBOMArray: JsonArray;
        JsonComponentAdditionalCostArray: JsonArray;
    begin
        LineNo := 0;
        TempVICComponentLocation.Reset();
        JsonComponentBOMArray := JsonComponentObj.GetArray('ComponentBOM');
        JsonComponentAdditionalCostArray := JsonComponentObj.GetArray('ComponentLabor');
        if TempVICComponentLocation.FindSet() then begin
            repeat
                ParseComponentAdditionalCosts(JsonComponentAdditionalCostArray, TempVICItemStructureLine, TempVICComponentLocation.LocationId, LineNo);
                ParseComponentBOM(JsonComponentBOMArray, TempVICItemStructureLine, TempVICComponentLocation.LocationId, LineNo);
            until TempVICComponentLocation.Next() = 0;
        end;

        // foreach Tok in JsonComponentBOMArray do begin
        //     Obj := Tok.AsObject();
        //     LineNo += 1;
        //     TempVICItemStructureLine.Init();
        //     TempVICItemStructureLine.LineNo := LineNo;
        //     TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
        //     TempVICItemStructureLine.FacilityId := Obj.GetText('LocationId');
        //     TempVICItemStructureLine.Level := 0;
        //     if Obj.GetInteger('LineType') = TempVICItemStructureLine.LineType::Component.AsInteger() then begin
        //         TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Component;
        //         TempVICItemStructureLine.Id := Obj.GetText('SubComponentId');
        //         if Item.Get(TempVICItemStructureLine.Id) then begin
        //             TempVICItemStructureLine.Description := Item.Description;
        //             if Obj.GetInteger('BOMQuantityType') + 1 = TempVICItemStructureLine.QtyType::PerParent.AsInteger() then
        //                 TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::PerParent
        //             else
        //                 TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::OfParent;
        //             TempVICItemStructureLine.Quantity := Obj.GetDecimal('BOMQuantity');
        //         end
        //         else begin
        //             TempVICItemStructureLine.Description := 'NOT FOUND';
        //         end
        //     end
        //     else begin
        //         TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Instruction;
        //         TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::Blank;
        //         TempVICItemStructureLine.Instruction := PadStr(Obj.GetText('Instruction', true), MaxStrLen(TempVICItemStructureLine.Instruction));
        //     end;
        //     TempVICItemStructureLine.Insert();
        // end;
    end;

    procedure ParseComponentBOM(JsonComponentBOMArray: JsonArray; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary; FacilityId: Text[15]; var LineNo: Integer)
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
        BOMFacilityId: Text[15];
    begin
        foreach Tok in JsonComponentBOMArray do begin
            Obj := Tok.AsObject();
            BOMFacilityId := Obj.GetText('LocationId');
            if BOMFacilityId <> FacilityId then
                continue;
            LineNo += 1;
            TempVICItemStructureLine.Init();
            TempVICItemStructureLine.LineNo := LineNo;
            TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
            TempVICItemStructureLine.FacilityId := FacilityId;
            TempVICItemStructureLine.Level := 0;
            if Obj.GetInteger('LineType') = TempVICItemStructureLine.LineType::Component.AsInteger() then begin
                TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Component;
                TempVICItemStructureLine.Id := Obj.GetText('SubComponentId');
                if Item.Get(TempVICItemStructureLine.Id) then begin
                    TempVICItemStructureLine.Description := Item.Description;
                    if Obj.GetInteger('BOMQuantityType') + 1 = TempVICItemStructureLine.QtyType::PerParent.AsInteger() then
                        TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::PerParent
                    else
                        TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::OfParent;
                    TempVICItemStructureLine.Quantity := Obj.GetDecimal('BOMQuantity');
                end
                else begin
                    TempVICItemStructureLine.Description := 'NOT FOUND';
                end
            end
            else begin
                TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Instruction;
                TempVICItemStructureLine.QtyType := TempVICItemStructureLine.QtyType::Blank;
                TempVICItemStructureLine.Instruction := PadStr(Obj.GetText('Instruction', true), MaxStrLen(TempVICItemStructureLine.Instruction));
            end;
            TempVICItemStructureLine.Insert();
        end;
    end;

    procedure ParseComponentAdditionalCosts(JsonComponentAdditionalCostArray: JsonArray; var TempVICItemStructureLine: Record pte_vic_ItemStructureLine temporary; FacilityId: Text[15]; var LineNo: Integer)
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        Item: Record Item;
        AdditionalCostFacilityId: Text[15];
    begin
        foreach Tok in JsonComponentAdditionalCostArray do begin
            Obj := Tok.AsObject();
            AdditionalCostFacilityId := Obj.GetText('LocationId');
            if AdditionalCostFacilityId <> FacilityId then
                continue;
            LineNo += 1;
            TempVICItemStructureLine.Init();
            TempVICItemStructureLine.LineNo := LineNo;
            TempVICItemStructureLine.ComponentId := Obj.GetText('ComponentId');
            TempVICItemStructureLine.FacilityId := FacilityId;
            TempVICItemStructureLine.Level := 0;
            if Obj.GetInteger('LineType') = 1 then
                TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Setup
            else
                TempVICItemStructureLine.LineType := TempVICItemStructureLine.LineType::Runtime;
            TempVICItemStructureLine.Id := Obj.GetText('LaborId');
            TempVICItemStructureLine.Quantity := Obj.GetDecimal('LaborTime');
            TempVICItemStructureLine.Insert();
        end;
    end;
}


