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
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");

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
                exit(ItemLedgerFilter);
            end else
                exit('Inserted');
        end else begin
            exit('Error: ' + GetLastErrorText);
        end;

        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    // V4-2009
    [ServiceEnabled]
    [Scope('Cloud')]
    procedure GetVicinityExtensionVersion() Output: Text
    var
        ModuleInfo: ModuleInfo;
        AppVersion: Version;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        AppVersion := ModuleInfo.AppVersion;
        exit(Format(AppVersion));
    end;
}