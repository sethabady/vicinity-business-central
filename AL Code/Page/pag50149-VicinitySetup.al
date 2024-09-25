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
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertGenJournal(postingdate: Date; documentno: Text; glaccountno: Text; glbalaccountno: Text; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean) Output: Text
    var
        actionContext: WebServiceActionContext;
        VicinityBCGenJournalMgmt: Codeunit "Vicinity BC Gen Journal Mgmt";
        GLRegister: Record "G/L Register";
        SourceCodeSetup: Record "Source Code Setup";
        GLFilter: Text;
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");

        SourceCodeSetup.Get();
        VicinityBCGenJournalMgmt.SetGenJournalParameters(postingdate, documentno, glaccountno, glbalaccountno, amount, batchnumber, facilityid, lineid, eventid, firstline, post, Rec);
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

        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    // V4-1753 : added lot expiration date


    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertItemJournal(postingdate: Date; documentno: Text; itemno: Text; locationcode: Text; bincode: Text; uomcode: Text; lotno: Text; qty: Decimal; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; firstline: Boolean; post: Boolean; lotexpirationdate: Date) Output: Text
    var
        actionContext: WebServiceActionContext;
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
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");

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
        VicinityBCItemJournalMgmt.SetItemJournalParameters(postingdate, documentno, itemno, locationcode, bincode, uomcode, lotno, qty, amount, batchnumber, facilityid, lineid, eventid, firstline, post, Rec, SourceCodeSetup, lotexpirationdate);
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
        vicinityRequisitionsJsonArray: JsonArray;
    begin
        vicinityRequisitionsJsonArray.ReadFrom(vicinityRequisitions);
        exit(VICRequisitionService.AddToWorksheet(worksheetTemplateName, journalBatchName, initialize,  vicinityRequisitionsJsonArray));
    end;
}