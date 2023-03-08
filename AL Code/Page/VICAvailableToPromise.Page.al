page 50146 "VICAvailableToPromise"
{
    Caption = 'Vicinity Available to Promise';
    DataCaptionExpression = PageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    SourceTable = "Inventory Page Data";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Period Start", "Line No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No.';
                    TableRelation = Item;
                    ToolTip = 'Specifies the item that availability is shown for.';

                    trigger OnValidate()
                    begin
                        ValidateItemNo();
                    end;
                }
                /*                 
                                field(ItemNo; ItemNo)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Item No.';
                                    TableRelation = Item;
                                    ToolTip = 'Specifies the item that availability is shown for.';

                                    trigger OnValidate()
                                    var
                                        TempItem: Record Item;
                                    begin
                                        if ItemNo <> Item."No." then begin
                                            if TempItem.Get(ItemNo) then begin
                                                SetItem(TempItem);
                                                Rec.DeleteAll();

                                                Rec.Init();
                                                Rec.Code := '';
                                                Rec."Line No." := 1;
                                                Rec.Description := 'Opening Balance';
                                                Rec."Projected Inventory" := 777;
                                                Rec.Level := 0;
                                                Rec.Insert();


                                                CurrPage.Update(false);
                                            end;
                                        end;
                                    end;
                                }
                 */
                field(Location; LocationCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Location Code';
                    TableRelation = Location;
                    ToolTip = 'Specifies the item that availability is shown for.';

                    trigger OnValidate()
                    begin
                        ValidateLocationCode();
                    end;
                }

                /*                 field(LocationFilter; LocationFilter)
                                {
                                    ApplicationArea = Location;
                                    Caption = 'Location Filter';
                                    ToolTip = 'Specifies the location that availability is shown for.';

                                    trigger OnLookup(var Text: Text): Boolean
                                    var
                                        Location: Record Location;
                                        LocationList: Page "Location List";
                                    begin
                                        LocationList.SetTableView(Location);
                                        LocationList.LookupMode := true;
                                        if LocationList.RunModal = ACTION::LookupOK then begin
                                            LocationList.GetRecord(Location);
                                            Text := Location.Code;
                                            exit(true);
                                        end;
                                        exit(false);
                                    end;

                                    trigger OnValidate()
                                    begin
                                        if LocationFilter <> Item.GetFilter("Location Filter") then begin
                                            Item.SetRange("Location Filter");
                                            if LocationFilter <> '' then
                                                Item.SetFilter("Location Filter", LocationFilter);
                                            Rec.DeleteAll();
                                            CalcVicinityATPPageDate.CreateVicinityATP(ItemNo, Location, Rec, IncludePlannedOrders);
                                            CurrPage.Update(false);
                                        end;
                                    end;
                                }
                */
                field(IncludePlannedOrders; IncludePlannedOrders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Include Planned Orders';
                    ToolTip = 'Specifies whether to include Vicinity firm planned orders in the availability figures.';
                    trigger OnValidate()
                    begin
                        Rec.DeleteAll();
                        CalcVicinityATPPageDate.CreateVicinityATP(ItemNo, LocationCode, Rec, IncludePlannedOrders);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control5)
            {
                Editable = false;
                IndentationColumn = Rec.Level;
                IndentationControls = Description;
                ShowAsTree = true;
                TreeInitialState = ExpandAll;
                ShowCaption = false;
                field("Date"; Rec."Period Start")
                {
                    Caption = 'Date';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the transaction date of the availability line. Batch procedure (ingredients, by/co products) and BOM plan start; batch end item end date; planned order due date; PO expected receipt date; and SO required date.';
                    Visible = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the description of the availability line.';
/* 
                    trigger OnDrillDown()
                    begin
                        HyperLink('vmp://VicinityDrillBack/?ProductID=BatchEntry&FacilityID=FMI&BatchNumber=A01-110514');
                    end;
 */
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the source of the availability line.';
                }
                field("Gross Requirement"; Rec."Gross Requirement")
                {
                    Caption = 'Demand';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies an ingredient, bill of material, or sales order shipment demand.';
                }
                field("Scheduled Receipt"; Rec."Scheduled Receipt")
                {
                    Caption = 'Replenishment';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies a purchase order, planned order, end-item, or by/co-product receipt.';
                }
                field("Projected Inventory"; Rec."Projected Inventory")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Available';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Enabled = false;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the item''s availability.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Emphasize := EmphasizeLine;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then begin end;
    end;

    trigger OnOpenPage()
    var
    begin
        IncludePlannedOrders := true;
        CalcVicinityATPPageDate.CreateVicinityATP(ItemNo, LocationCode, Rec, IncludePlannedOrders);
    end;

    local procedure EmphasizeLine(): Boolean
    begin
        exit(Rec.Level = 0);
    end;

    var
        Item: Record Item;
        Location: Record Location;
        LocationCode: Code[10];
        LocationFilter: Text;
        CalcVicinityATPPageDate: Codeunit "VICATPManagement";
        ItemNo: Code[20];
        [InDataSet]
        IncludePlannedOrders: Boolean;
        [InDataSet]
        Emphasize: Boolean;

    local procedure PageCaption(): Text[250]
    begin
        exit(StrSubstNo('%1 %2', Item."No.", Item.Description));
    end;

    procedure SetItem(var NewItem: Record Item)
    begin
        Item.Copy(NewItem);
        UpdateItemRequestFields(Item);
    end;

    procedure SetLocation(var NewLocation: Record Location)
    begin
        Location.Copy(NewLocation);
        LocationCode := Location.Code;
        //        LocationFilter := NewLocation;
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

    local procedure ItemIsSet(): Boolean
    begin
        exit(Item."No." <> '');
    end;

    protected procedure ValidateItemNo()
    begin
        if ItemNo <> Item."No." then begin
            Item.Get(ItemNo);
            if LocationFilter <> '' then
                Item.SetFilter("Location Filter", LocationFilter);
            //            OnValidateItemNoOnBeforeInitAndCalculatePeriodEntries(Item);
            OnValidateItemNo(Item);
            Rec.DeleteAll();
            CalcVicinityATPPageDate.CreateVicinityATP(ItemNo, LocationCode, Rec, IncludePlannedOrders);

            //            InitAndCalculatePeriodEntries();
            CurrPage.Update(false);
        end;
    end;

    protected procedure ValidateLocationCode()
    begin
        if LocationCode <> Location.Code then begin
            Location.Get(LocationCode);
            OnValidateLocation(Location);
            /*             Item.Get(ItemNo);
                        if LocationFilter <> '' then
                            Item.SetFilter("Location Filter", LocationFilter);
            //            OnValidateItemNoOnBeforeInitAndCalculatePeriodEntries(Item);
                        OnValidateItemNo(Item);
             */
            Rec.DeleteAll();
            CalcVicinityATPPageDate.CreateVicinityATP(ItemNo, LocationCode, Rec, IncludePlannedOrders);

            //            InitAndCalculatePeriodEntries();
            CurrPage.Update(false);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateItemNo(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocation(var Location: Record Location)
    begin
    end;
}
