page 50334 "VICItemStructure"
{
    Caption = 'Vicinity Item Structure';
    DataCaptionExpression = ItemStructurePageCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SourceTable = VICItemStructurePageData;
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
            group(Options)
            {
                Caption = 'Options';
                field(DefaultFacilityId; DefaultFacilityId)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Default Facility ID';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(FacilityId; LocalFacilityId)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facility ID';
                    TableRelation = VICFacility.FacilityId;

                    // trigger OnValidate()
                    // begin
                    //     if LocalFacilityId = '' then
                    //         Error('Facility ID cannot be empty.')
                    //     else begin
                    //         // Validate that FacilityId exists in VICFacilityTemp
                    //         if not VICFacilityTemp.Get(LocalFacilityId) then
                    //             Error('Facility ID %1 does not exist.', LocalFacilityId);
                    //     end;
                    // end;

                    // trigger OnLookup(var Text: Text): Boolean
                    // var
                    // begin
                    //     if page.RunModal(Page::"Facility Lookup", VICFacilityTemp) = Action::LookupOK then
                    //         Text := VICFacilityTemp.FacilityId;
                    //     exit(true);
                    // end;
                }
                field(FormulaId; FormulaId)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Formula ID';
                    Editable = false;
                }
                field(FillQuantityPerStockingUnit; FillQuantityPerStockingUnit)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fill Quantity Per Stocking Unit';
                    Editable = false;
                }
                field(FillQuantityUnitOfMeasure; FillQuantityUnitOfMeasure)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fill Quantity Unit Of Measure';
                    Editable = false;
                }
                field(FormulaSourceType; FormulaSourceType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Formula Source Type';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineId; MachineId)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine ID';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineCapacity; MachineCapacity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine Capacity';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
                field(MachineCapacityUnitOfMeasure; MachineCapacityUnitOfMeasure)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine Capacity Unit Of Measure';
                    Editable = false;
                    // ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                }
            }
            repeater(Control1)
            {
                Editable = false;
                IndentationColumn = Rec.Level;
                IndentationControls = Description;
                ShowAsTree = true;
                TreeInitialState = ExpandAll;
                ShowCaption = false;
                field(Type; Rec.LineType)
                {
                    Caption = 'Type';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                    ApplicationArea = Basic, Suite;
                    Editable = false;
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
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    // ToolTip = 'Specifies the description of the availability line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    // ToolTip = 'Specifies the quantity of the availability line.';    
                }
            }
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
        VICJSONUtilities: Codeunit VICJSONUtilities;
        VICWebServiceInterface: Codeunit VICWebApiInterface;
        VICFacilityTemp: Record VICFacilityTemp temporary;
        VICDrillbackUrl: Text[200];
        VICComponentJson: JsonObject;
        Item: Record Item temporary;


        DefaultFacilityId: Code[15];
        LocalFacilityId: Code[15];
        FormulaId: Code[32];
        FillQuantityPerStockingUnit: Decimal;
        FillQuantityUnitOfMeasure: Text[20];
        FormulaSourceType: Enum FormulaSourceType;
        MachineId: Text[20];
        MachineCapacity: Decimal;
        MachineCapacityUnitOfMeasure: Code[10];
        Emphasize: Boolean;

    protected var
        // ItemNo: Code[20];

        //        TempInvtPageData: Record "Inventory Page Data" temporary;

        LocationFilter: Text;
        VariantFilter: Text;
        PeriodType: Option Day,Week,Month,Quarter,Year;

    procedure SetItem(var NewItem: Record Item)
    begin
        Item.Copy(NewItem);
        //        UpdateItemRequestFields(Item);
    end;

    local procedure ItemStructurePageCaption(): Text[250]
    begin
        exit(StrSubstNo('%1 %2', Item."No.", Item.Description));
    end;

    trigger OnAfterGetRecord()
    begin
        Emphasize := EmphasizeLine;
        // if rec.VicinityEntityType = 0 then
        //     EnableShowDocumentAction := false
        // else
        //     EnableShowDocumentAction := true;
    end;

    trigger OnOpenPage()
    var
        VICSetup: Record "Vicinity Setup";
        IsHandled: Boolean;
        IdIndex: Dictionary of [Text, Text];
        ComponentObj: JsonObject;
        VICComponent: Record VICComponent temporary;
        VICComponentLocation: Record VICComponentLocation temporary;
        LineNo: Integer;
    begin
        // Load Vicinity Setup
        if VICSetup.Get() then
            VICDrillbackUrl := VICSetup.VicinityDrillbackUrl;

        VICWebServiceInterface.OnFetchVICComponent(Item."No.", IsHandled, VICComponentJson);
        // IdIndex := DummyIndex();

        // // Build lookup so {"$ref":"4"} can be resolved anywhere
        // BuildIdIndex(VICComponentJson.AsToken(), IdIndex);

        // Root.Component
        ComponentObj := VICComponentJson.GetObject('Component'); // GetObjectByPath(VICComponentJson, 'Component', IdIndex);

        // Parse into temporary tables.
        ParseComponent(ComponentObj, VICComponent);
        ParseLocations(ComponentObj.GetArray('ComponentLocations'), VICComponentLocation);

        VICComponent.Get(Item."No.");
        DefaultFacilityId := VICComponent.DefaultFacilityId;
        if VICComponentLocation.Get(VICComponent.ComponentId, VICComponent.DefaultFacilityId) then begin
            LocalFacilityId := VICComponentLocation.LocationId;
            FormulaId := VICComponentLocation.FormulaId;
            FillQuantityPerStockingUnit := VICComponentLocation.FillQuantityPerStockingUnit;
            FillQuantityUnitOfMeasure := VICComponentLocation.FillQuantityUnitOfMeasure;
            FormulaSourceType := VICComponentLocation.FormulaSourceType;
            MachineId := VICComponentLocation.MachineId;
            MachineCapacity := VICComponentLocation.MachineCapacity;
            MachineCapacityUnitOfMeasure := VICComponentLocation.MachineCapacityUnitOfMeasure;
        end;

        LineNo := 0;
        Rec.Reset();
        Rec.DeleteAll();
        ParseComponentLabor(ComponentObj.GetArray('ComponentLabor'), Rec, LineNo, DefaultFacilityId);
        ParseComponentBOM(ComponentObj.GetArray('ComponentBOM'), Rec, LineNo, DefaultFacilityId);

        // ParseComponentLabor(GetArray(ComponentObj, 'ComponentLabor', IdIndex), IdIndex, Rec, LineNo, DefaultFacilityId);
        // ParseComponentBOM(GetArray(ComponentObj, 'ComponentBOM', IdIndex), IdIndex, Rec, LineNo, DefaultFacilityId);

        VICWebServiceInterface.OnFetchTempVICFacilities(VICFacilityTemp);

        // VICFacilityTemp.Reset();
        // VICFacilityTemp.SetCurrentKey(FacilityId);
        // if VICFacilityTemp.FindSet() then
        //     repeat
        //         Message('Temp Facility ID: %1, Name: %2', VICFacilityTemp.FacilityId, VICFacilityTemp.Name);
        //     until VICFacilityTemp.Next() = 0;
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

    local procedure ParseComponentLabor(LocArr: JsonArray; var TempVICItemStructurePageData: Record VICItemStructurePageData temporary; var LineNo: Integer; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;
        LocationId: Text[15];
    begin
        LineNo += 1;
        TempVICItemStructurePageData.Init();
        TempVICItemStructurePageData.LineNo := LineNo;
        TempVICItemStructurePageData.Level := 0;
        TempVICItemStructurePageData.Description := 'Routing';
        TempVICItemStructurePageData.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject(); // ResolveToObject(Tok, IdIndex);
            LocationId := Obj.GetText('LocationId');
            if LocationId = FacilityId then begin
                LineNo += 1;
                TempVICItemStructurePageData.Init();
                TempVICItemStructurePageData.LineNo := LineNo;
                TempVICItemStructurePageData.Level := 1;
                if Obj.GetInteger('LineType') = 2 then
                    TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Setup
                else
                    TempVICItemStructurePageData.LineType := TempVICItemStructurePageData.LineType::Runtime;
                TempVICItemStructurePageData.Id := Obj.GetText('LaborId'); //
                TempVICItemStructurePageData.ComponentId := Obj.GetText('ComponentId'); 
                TempVICItemStructurePageData.FacilityId := Obj.GetText('LocationId');
                TempVICItemStructurePageData.Description := Obj.GetText('Description', true);
                TempVICItemStructurePageData.Quantity := Obj.GetDecimal('LaborTime');
                TempVICItemStructurePageData.Insert();
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

    local procedure ParseComponentBOM(LocArr: JsonArray; var TempVICItemStructurePageData: Record VICItemStructurePageData temporary; var LineNo: Integer; FacilityId: Text[15])
    var
        i: Integer;
        Tok: JsonToken;
        Obj: JsonObject;

    begin
        LineNo += 1;
        TempVICItemStructurePageData.Init();
        TempVICItemStructurePageData.LineNo := LineNo;
        TempVICItemStructurePageData.Level := 0;
        TempVICItemStructurePageData.Description := 'Bill of Materials';
        TempVICItemStructurePageData.Insert();
        foreach Tok in LocArr do begin
            Obj := Tok.AsObject();
            LineNo += 1;
            if Obj.GetText('LocationId') = FacilityId then begin
                TempVICItemStructurePageData.Init();
                TempVICItemStructurePageData.LineNo := LineNo;
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

    // local procedure DummyIndex(): Dictionary of [Text, Text]
    // var
    //     D: Dictionary of [Text, Text];
    // begin
    //     exit(D);
    // end;

    // // ---------------------------
    // // $id / $ref support
    // // ---------------------------

    // local procedure BuildIdIndex(Tok: JsonToken; var IdIndex: Dictionary of [Text, Text])
    // var
    //     Obj: JsonObject;
    //     Arr: JsonArray;
    //     i: Integer;
    //     PropNames: List of [Text];
    //     Name: Text;
    //     ChildTok: JsonToken;
    //     IdValue: Text;
    //     AsText: Text;
    // begin
    //     if Tok.IsObject() then begin
    //         Obj := Tok.AsObject();

    //         if Obj.Get('$id', ChildTok) then begin
    //             IdValue := ChildTok.AsValue().AsText();
    //             if Tok.IsValue() then begin
    //                 AsText := Tok.AsValue().AsText(); // JSON text for this object
    //                 if (IdValue <> '') and (not IdIndex.ContainsKey(IdValue)) then
    //                     IdIndex.Add(IdValue, AsText);
    //             end;
    //         end;

    //         PropNames := Obj.Keys();
    //         foreach Name in PropNames do
    //             if Obj.Get(Name, ChildTok) then
    //                 BuildIdIndex(ChildTok, IdIndex);

    //         exit;
    //     end;

    //     if Tok.IsArray() then begin
    //         Arr := Tok.AsArray();
    //         for i := 0 to Arr.Count() - 1 do begin
    //             Arr.Get(i, ChildTok);
    //             BuildIdIndex(ChildTok, IdIndex);
    //         end;
    //     end;
    // end;

    // local procedure ResolveToObject(Tok: JsonToken; var IdIndex: Dictionary of [Text, Text]): JsonObject
    // var
    //     Obj: JsonObject;
    //     RefTok: JsonToken;
    //     RefId: Text;
    //     RefJson: Text;
    // begin
    //     if Tok.IsObject() then begin
    //         Obj := Tok.AsObject();

    //         // If it is a {$ref:"x"} object, resolve from index
    //         if Obj.Get('$ref', RefTok) then begin
    //             RefId := RefTok.AsValue().AsText();
    //             if (RefId <> '') and IdIndex.Get(RefId, RefJson) then begin
    //                 Obj.ReadFrom(RefJson);
    //                 exit(Obj);
    //             end;
    //         end;

    //         exit(Obj);
    //     end;

    //     exit(Obj); // empty
    // end;

    // local procedure GetObjectByPath(Root: JsonObject; PropertyName: Text; var IdIndex: Dictionary of [Text, Text]): JsonObject
    // var
    //     Tok: JsonToken;
    //     Obj: JsonObject;
    // begin
    //     if not Root.Get(PropertyName, Tok) then
    //         exit(Obj);

    //     exit(ResolveToObject(Tok, IdIndex));
    // end;

    // local procedure GetArray(ParentObj: JsonObject; PropertyName: Text; var IdIndex: Dictionary of [Text, Text]): JsonArray
    // var
    //     Tok: JsonToken;
    //     Arr: JsonArray;
    //     Obj: JsonObject;
    // begin
    //     if not ParentObj.Get(PropertyName, Tok) then
    //         exit(Arr);

    //     if Tok.IsValue() then begin
    //         if Tok.AsValue().IsNull() then
    //             exit(Arr)
    //     end;

    //     // arrays in your sample are not $ref directly, but keep it safe:
    //     if Tok.IsObject() then begin
    //         Obj := ResolveToObject(Tok, IdIndex);
    //         if Obj.Get(PropertyName, Tok) and Tok.IsArray() then
    //             exit(Tok.AsArray());
    //         exit(Arr);
    //     end;

    //     if Tok.IsArray() then
    //         exit(Tok.AsArray());

    //     exit(Arr);
    // end;

}
