page 50149 "Vicinity Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Vicinity Setup";
    Caption = 'Vicinity Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Vicinity Enabled"; Rec."Vicinity Enabled")
                {
                    ApplicationArea = All;

                }
                field("Gen. Journal Batch"; Rec."Gen. Journal Batch")
                {
                    ApplicationArea = All;

                }

                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = All;

                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;

                }
                field("Warehousing Enabled"; Rec."Warehousing Enabled")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Warehouse Journal Batch"; Rec."Warehouse Journal Batch")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API URL"; Rec."ApiUrl")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity Company ID"; Rec."CompanyId")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API User Name"; Rec.ApiUserName)
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API Access Key"; Rec.ApiAccessKey)
                {
                    ExtendedDatatype = Masked;
                    Visible = true;
                    ApplicationArea = All;
                }
            }
        }
    }

    /* 
        actions
        {
            area(Processing)
            {
                action("My Actions")
                {
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        HyperLink('vmp://VicinityDrillBack/?ProductID=BatchEntry&FacilityID=FMI&BatchNumber=A01-110514');                    
                        Message('Hello World');
                    end;
                }            
            }
        }
     */

    // V4-2337
    var
        HasGotGLSetup: Boolean;

    // V4-2337 : support for dimensions
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertGeneralJournalJson(psVicinityGeneralJournalJson: Text) Output: Text
    var
        lcuVICJsonUtilities: Codeunit VICJSONUtilities;
        actionContext: WebServiceActionContext;
        ljtVicinityGeneralJournal: JsonToken;
        ldtPostingDate: Date;
        lsDocumentNo: Text;
        lsGlAccountNo: Text;
        lsGlBalAccountNo: Text;
        ldAmount: Decimal;
        lsBatchNumber: Text;
        lsFacilityId: Text;
        liLineId: Integer;
        liEventId: Integer;
        lbFirstLine: Boolean;
        lbPost: Boolean;
        lsGlobalDimensionCode1: Text;
        lsGlobalDimensionCode2: Text;
        lsOutputText: Text;
        lcodGenBusPostingGroup: Code[20];
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");
        ljtVicinityGeneralJournal.ReadFrom(psVicinityGeneralJournalJson);
        ldtPostingDate := DT2Date(lcuVICJsonUtilities.GetDateFromJson(ljtVicinityGeneralJournal, 'PostingDate'));
        lsDocumentNo := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'DocumentNo');
        lsGlAccountNo :=lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'GLAccountNo');
        lsGlBalAccountNo := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'GLBalAccountNo');
        ldAmount := lcuVICJsonUtilities.GetDecimalFromJson(ljtVicinityGeneralJournal, 'Amount');
        lsBatchNumber := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'BatchNumber');
        lsFacilityId := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'FacilityId');
        liLineId := lcuVICJsonUtilities.GetIntegerFromJson(ljtVicinityGeneralJournal, 'LineId');
        liEventId := lcuVICJsonUtilities.GetIntegerFromJson(ljtVicinityGeneralJournal, 'EventId');
        lbFirstLine := lcuVICJsonUtilities.GetBooleanFromJson(ljtVicinityGeneralJournal, 'FirstLine');
        lsGlobalDimensionCode1 := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'GlobalDimensionCode1');
        lsGlobalDimensionCode2 := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'GlobalDimensionCode2');
        lbPost := lcuVICJsonUtilities.GetBooleanFromJson(ljtVicinityGeneralJournal, 'Post');
        lcodGenBusPostingGroup := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityGeneralJournal, 'GeneralBusinessPostingGroup');
        lsOutputText := processInsertGeneralJournalCall(ldtPostingDate, lsDocumentNo, lsGlAccountNo, lsGlBalAccountNo, ldAmount, lsBatchNumber, lsFacilityId, liLineId, liEventId, lbFirstLine, lbPost, lsGlobalDimensionCode1, lsGlobalDimensionCode2, lcodGenBusPostingGroup);
        exit (lsOutputText);
        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    local procedure processInsertGeneralJournalCall(postingdate: Date; documentno: Text; glaccountno: Text; glbalaccountno: Text; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean; psGlobalDimension1: Text[20]; psGlobalDimension2: Text[20]; pcodGenBusPostingGroup: Code[20]) Output: Text
    var
        VicinityBCGenJournalMgmt: Codeunit "Vicinity BC Gen Journal Mgmt";
        GLRegister: Record "G/L Register";
        SourceCodeSetup: Record "Source Code Setup";
        GLFilter: Text;
    begin
        SourceCodeSetup.Get();
        VicinityBCGenJournalMgmt.SetGenJournalParameters(postingdate, documentno, glaccountno, glbalaccountno, amount, batchnumber, facilityid, lineid, eventid, firstline, post, Rec, psGlobalDimension1, psGlobalDimension2, pcodGenBusPostingGroup);
        if VicinityBCGenJournalMgmt.Run() = true then begin
            if post then begin
                GLRegister.Reset();
                GLRegister.SetRange("Source Code", SourceCodeSetup."General Journal");
                GLRegister.SetRange("Journal Batch Name", Rec."Gen. Journal Batch");
                GLRegister.SetRange("User ID", UserId);
                GLRegister.FindLast();
                if GLRegister."From Entry No." = GLRegister."To Entry No." then
                    GLFilter := StrSubstNo('Entry_No eq %1', GLRegister."From Entry No.")
                else
                    GLFilter := StrSubstNo('Entry_No ge %1 and Entry_No le %2', GLRegister."From Entry No.", GLRegister."To Entry No.");
                exit(GLFilter);
            end else
                exit('Inserted');
        end else begin
            exit('Error: ' + GetLastErrorText);
        end;
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertGenJournal(postingdate: Date; documentno: Text; glaccountno: Text; glbalaccountno: Text; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean) Output: Text
    var
        actionContext: WebServiceActionContext;
        VicinityBCGenJournalMgmt: Codeunit "Vicinity BC Gen Journal Mgmt";
        GLRegister: Record "G/L Register";
        SourceCodeSetup: Record "Source Code Setup";
        GLFilter: Text;
        lsOutputText: Text;
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");
        SourceCodeSetup.Get();
        lsOutputText := processInsertGeneralJournalCall(postingdate, documentno, glaccountno, glbalaccountno, amount, batchnumber, facilityid, lineid, eventid, firstline, post, '', '', '');
        exit(lsOutputText);
        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    // V4-2337 : support for dimensions
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertItemJournalJson(psVicinityItemJournalJson: Text) Output: Text
    var
        lcuVICJsonUtilities: Codeunit VICJSONUtilities;
        actionContext: WebServiceActionContext;
        ljtVicinityInventoryTransaction: JsonToken;
        ldtPostingDate: Date;
        lsDocumentNo: Text;
        lsItemNo: Text;
        lsLocationCode: Text;
        lsBinCode: Text;
        lsUOMCode: Text;
        lsLotNo: Text;
        ldQty: Decimal;
        ldAmount: Decimal;
        lsBatchNumber: Text;
        lsFacilityId: Text;
        liLineId: Integer;
        liEventId: Integer;
        lbFirstLine: Boolean;
        lbPost: Boolean;
        ldtLotExpirationDate: Date;
        lsGlobalDimensionCode1: Text;
        lsGlobalDimensionCode2: Text;
        lsOutputText: Text;
        lcodGenBusPostingGroup: Code[20];
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");
        ljtVicinityInventoryTransaction.ReadFrom(psVicinityItemJournalJson);
        ldtPostingDate := DT2Date(lcuVICJsonUtilities.GetDateFromJson(ljtVicinityInventoryTransaction, 'PostingDate'));
        lsDocumentNo := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'DocumentNo');
        lsItemNo := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'ItemNo');
        lsLocationCode := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'LocationCode');
        lsBinCode := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'BinCode');
        lsUOMCode := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'UOMCode');
        lsLotNo := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'LotNo');
        ldQty := lcuVICJsonUtilities.GetDecimalFromJson(ljtVicinityInventoryTransaction, 'Qty');
        ldAmount := lcuVICJsonUtilities.GetDecimalFromJson(ljtVicinityInventoryTransaction, 'Amount');
        lsBatchNumber := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'BatchNumber');
        lsFacilityId := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'FacilityId');
        liLineId := lcuVICJsonUtilities.GetIntegerFromJson(ljtVicinityInventoryTransaction, 'LineId');
        liEventId := lcuVICJsonUtilities.GetIntegerFromJson(ljtVicinityInventoryTransaction, 'EventId');
        lbFirstLine := lcuVICJsonUtilities.GetBooleanFromJson(ljtVicinityInventoryTransaction, 'FirstLine');
        ldtLotExpirationDate := DT2Date(lcuVICJsonUtilities.GetDateFromJson(ljtVicinityInventoryTransaction, 'LotExpirationDate'));
        lsGlobalDimensionCode1 := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'GlobalDimensionCode1');
        lsGlobalDimensionCode2 := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'GlobalDimensionCode2');
        lbPost := lcuVICJsonUtilities.GetBooleanFromJson(ljtVicinityInventoryTransaction, 'Post');
        lcodGenBusPostingGroup := lcuVICJsonUtilities.GetTextFromJson(ljtVicinityInventoryTransaction, 'GeneralBusinessPostingGroup');
        lsOutputText := processInsertItemJournalCall(ldtPostingDate, lsDocumentNo, lsItemNo, lsLocationCode, lsBinCode, lsUOMCode, lsLotNo, ldQty, ldQty, lsBatchNumber, lsFacilityId, liLineId, liEventId, lbFirstLine, lbPost, ldtLotExpirationDate, lsGlobalDimensionCode1, lsGlobalDimensionCode2, lcodGenBusPostingGroup);
        exit (lsOutputText);
        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    local procedure processInsertItemJournalCall(postingdate: Date; documentno: Text; itemno: Text; locationcode: Text; bincode: Text; uomcode: Text; lotno: Text; qty: Decimal; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean; lotexpirationdate: Date; psGlobalDimension1: Text[20]; psGlobalDimension2: Text[20]; pcodGenBusPostingGroup: Code[20]) Output: Text
    var
        VicinityBCItemJournalMgmt: Codeunit "Vicinity BC Item Journal Mgmt";
        ItemRegister: Record "Item Register";
        SourceCodeSetup: Record "Source Code Setup";
        ItemLedgerFilter: Text;
        ItemLedgerEntry: Record "Item Ledger Entry";

        // V4-2101
        JsonILEArray: JsonArray;
        JsonILEObject: JsonObject;
        ReturnJsonText: Text;
        CostAmount: Decimal;
        ValueEntry: Record "Value Entry";
        DuplicateFound: Boolean;
    begin
        DuplicateFound := false;
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Vicinity Batch No.", "Vicinity Facility ID", "Vicinity Line ID No.", "Vicinity Event ID No.");
        ItemLedgerEntry.SetRange("Vicinity Facility ID", facilityid);
        ItemLedgerEntry.SetRange("Vicinity Batch No.", batchnumber);
        ItemLedgerEntry.SetRange("Vicinity Line ID No.", lineid);
        ItemLedgerEntry.SetRange("Vicinity Event ID No.", eventid);
        if ItemLedgerEntry.FindFirst() then
            DuplicateFound := true;

        // Only return ILE records if post was called.

        // Don't write a record to journal if it has already been posted and written to ILE.
        if DuplicateFound and not post then begin
            // Not posting and the record needs to be skipped.
            exit(BuildReturnJson('', '', '', 'Skipped'));
        end;
        if DuplicateFound and post and firstLine then begin
            // V4-2101
            // Posting but this record is a duplicate and no other records have been written so skip.
            exit(BuildReturnJson(facilityId, batchNumber, '', 'Skipped'));
        end;
        if DuplicateFound then begin
            // We're not skipping because we are posting, but we don't want to write current record because it is a duplicate.
            itemno := '';
        end;

        SourceCodeSetup.Get();

        // V4-2337 : global dimensions
        VicinityBCItemJournalMgmt.SetItemJournalParameters(postingdate, documentno, itemno, locationcode, bincode, uomcode, lotno, qty, amount, batchnumber, facilityid, lineid, eventid, firstline, post, Rec, SourceCodeSetup, lotexpirationdate, psGlobalDimension1, psGlobalDimension2, pcodGenBusPostingGroup);
        if VicinityBCItemJournalMgmt.Run() = true then begin
            if post then begin
                ItemRegister.Reset();
                ItemRegister.SetRange("Source Code", SourceCodeSetup."Item Journal");
                ItemRegister.SetRange("Journal Batch Name", Rec."Item Journal Batch");
                ItemRegister.SetRange("User ID", UserId);
                ItemRegister.FindLast();
                if ItemRegister."From Entry No." = ItemRegister."To Entry No." then
                    ItemLedgerFilter := StrSubstNo('EntryNo eq %1', ItemRegister."From Entry No.")
                else
                    ItemLedgerFilter := StrSubstNo('EntryNo ge %1 and EntryNo le %2', ItemRegister."From Entry No.", ItemRegister."To Entry No.");

                // V4-2101
                ReturnJsonText := BuildReturnJson(facilityId, batchNumber, ItemLedgerFilter, 'Posted');
                exit(ReturnJsonText);
            end else begin
                exit(BuildReturnJson('', '', '', 'Inserted'));
            end
        end else begin
            if post then begin
                // Query and return ItemLE records when the ItemJournal is posted.
                exit(BuildReturnJson(facilityid, batchnumber, '', 'Error: ' + GetLastErrorText()))
            end
            else
                exit(BuildReturnJson('', '', '', 'Error: ' + GetLastErrorText()))
        end;
    end;

    // V4-1753 : added lot expiration date
    // V4-2337 : global dimensions
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertItemJournal(postingdate: Date; documentno: Text; itemno: Text; locationcode: Text; bincode: Text; uomcode: Text; lotno: Text; qty: Decimal; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean; lotexpirationdate: Date) Output: Text
    var
        actionContext: WebServiceActionContext;
        lsOutputText: Text;
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");
        lsOutputText := processInsertItemJournalCall(postingdate, documentno, itemno, locationcode, bincode, uomcode, lotno, qty, amount, batchnumber, facilityid, lineid, eventid, firstline, post, lotexpirationdate, '', '', '');
        exit(lsOutputText);
        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    // V4-2101
    local procedure BuildReturnJson(facilityId: text; batchNumber: text; itemLedgerFilter: text; message: text) returnJsonText: Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        JsonILEArray: JsonArray;
        JsonILEObject: JsonObject;
        JsonReturnObject: JsonObject;
        CostAmount: Decimal;
        ValueEntry: Record "Value Entry";
        ModuleInfo: ModuleInfo;
        AppVersion: Version;
    begin
        JsonReturnObject.Add('Message', message);
        JsonReturnObject.Add('ItemLedgerFilter', itemLedgerFilter);

        NavApp.GetCurrentModuleInfo(ModuleInfo);
        AppVersion := ModuleInfo.AppVersion;

        JsonReturnObject.Add('VicinityExtensionVersion', Format(AppVersion));
        if batchNumber <> '' then begin
            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetCurrentKey("Vicinity Batch No.", "Vicinity Facility ID", "Vicinity Line ID No.", "Vicinity Event ID No.");
            ItemLedgerEntry.SetRange("Vicinity Facility ID", facilityId);
            ItemLedgerEntry.SetRange("Vicinity Batch No.", batchNumber);
            if ItemLedgerEntry.FindSet() then begin
                repeat
                    JsonILEObject.Add('EventIdNo', ItemLedgerEntry."Vicinity Event ID No.");
                    JsonILEObject.Add('LineIdNo', ItemLedgerEntry."Vicinity Line ID No.");
                    ValueEntry.Reset();
                    ValueEntry.SetCurrentKey(ValueEntry."Entry No.");
                    ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    CostAmount := 0;
                    if ValueEntry.CalcSums("Cost Amount (Actual)") then
                        CostAmount := ValueEntry."Cost Amount (Actual)";
                    JsonILEObject.Add('ExtendedCost', CostAmount);
                    JsonILEObject.Add('ErpDocumentNo', ItemLedgerEntry."Document No.");
                    JsonILEObject.Add('EntryNo', ItemLedgerEntry."Entry No.");
                    JsonILEArray.Add(JsonILEObject);
                    Clear(JsonILEObject);
                until ItemLedgerEntry.Next() = 0;
            end
        end;
        JsonReturnObject.Add('ItemLedgerEntries', JsonILEArray);
        JsonReturnObject.WriteTo(returnJsonText);
        exit(returnJsonText);
    end;

    // V4-2009
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure GetVicinityExtensionVersion() Output: Text
    var
        actionContext: WebServiceActionContext;
        ModuleInfo: ModuleInfo;
        AppVersion: Version;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        AppVersion := ModuleInfo.AppVersion;
        exit(Format(AppVersion));
        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure AddToRequisitionWorksheet(worksheetTemplateName: Text; journalBatchName: Text; initialize: Boolean; vicinityRequisitions: Text) Output: Text
    var
        VICRequisitionService: Codeunit VICRequisitionService;
        VicinityRequisitionsJsonArray: JsonArray;
    begin
        VicinityRequisitionsJsonArray.ReadFrom(vicinityRequisitions);
        exit(VICRequisitionService.AddToWorksheet(worksheetTemplateName, journalBatchName, initialize, VicinityRequisitionsJsonArray));
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure AddToStandardCostWorksheet(worksheetName: Text; initialize: Boolean; standardCostWorksheets: Text) Output: Text
    var
        VICStandardCostService: Codeunit VICStandardCostService;
        vicinityStandardCostWorksheetsJsonArray: JsonArray;
    begin
        vicinityStandardCostWorksheetsJsonArray.ReadFrom(standardCostWorksheets);
        exit(VICStandardCostService.AddToStandardCostWorksheet(worksheetName, initialize, VicinityStandardCostWorksheetsJsonArray));
    end;

    // V4-2337
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure GetBCDimensions() Output: Text
    var
        GLSetup: Record "General Ledger Setup";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        GLSetupShortcutDimCode: array[8] of Code[20];
        GLSetupGlobalDimCode: array[2] of Code[20];
        GLSetupGlobalDimFilter: array[2] of Code[20];
        JsonReturnObject: JsonObject;
        JsonDimensionObject: JsonObject;
        JsonDimensionValueObject: JsonObject;
        JsonDimensionArray: JsonArray;
        JsonDimensionValueArray: JsonArray;
        JsonReturnText: Text;
    begin
        if not HasGotGLSetup then begin
            GLSetup.Get();
            GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
            GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
            GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
            GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
            GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
            GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
            GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
            GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
            GLSetupGlobalDimCode[1] := GLSetup."Global Dimension 1 Code";
            GLSetupGlobalDimFilter[1] := GLSetup."Global Dimension 1 Filter";
            GLSetupGlobalDimCode[2] := GLSetup."Global Dimension 2 Code";
            GLSetupGlobalDimFilter[2] := GLSetup."Global Dimension 1 Filter";
            HasGotGLSetup := true;
        end;
        JsonReturnObject.Add('GlobalDimension1Code', GLSetupGlobalDimCode[1]);
        JsonReturnObject.Add('GlobalDimension2Code', GLSetupGlobalDimCode[2]);
        JsonReturnObject.Add('GlobalDimension1CodeFilter', GLSetupGlobalDimFilter[1]);
        JsonReturnObject.Add('GlobalDimension2CodeFilter', GLSetupGlobalDimFilter[2]);
        Dimension.Reset();
        if Dimension.FindSet() then begin
            repeat
                JsonDimensionObject.Add('Code', Dimension.Code);
                JsonDimensionObject.Add('Name', Dimension.Name);
                DimensionValue.SetRange("Dimension Code", Dimension.Code);
                if DimensionValue.FindSet() then begin
                    repeat
                        JsonDimensionValueObject.Add('DimensionCode', DimensionValue."Dimension Code");
                        JsonDimensionValueObject.Add('Code', DimensionValue."Code");
                        JsonDimensionValueObject.Add('Name', DimensionValue.Name);
                        JsonDimensionValueObject.Add('DimensionValueType', DimensionValue."Dimension Value Type");
                        JsonDimensionValueObject.Add('DimensionValueID', DimensionValue."Dimension Value ID");
                        JsonDimensionValueArray.Add(JsonDimensionValueObject);
                        Clear(JsonDimensionValueObject);
                    until DimensionValue.Next() = 0;
                    JsonDimensionObject.Add('DimensionValues', JsonDimensionValueArray);
                    Clear(JsonDimensionValueArray);
                end;
                JsonDimensionArray.Add((JsonDimensionObject));
                Clear(JsonDimensionObject);
            until Dimension.Next() = 0;
        end;
        JsonReturnObject.Add('Dimensions', JsonDimensionArray);
        JsonReturnObject.WriteTo(JsonReturnText);
        exit(JsonReturnText);
    end;
}