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
                field("Vicinity Enabled"; "Vicinity Enabled")
                {
                    ApplicationArea = All;

                }
                field("Gen. Journal Batch"; "Gen. Journal Batch")
                {
                    ApplicationArea = All;

                }

                field("Item Journal Batch"; "Item Journal Batch")
                {
                    ApplicationArea = All;

                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;

                }
                field("Warehousing Enabled"; "Warehousing Enabled")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Warehouse Journal Batch"; "Warehouse Journal Batch")
                {
                    Visible = false;
                    ApplicationArea = All;

                }

            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertGenJournal(postingdate: Date; documentno: Text; glaccountno: Text; glbalaccountno: Text; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; post: Boolean) Output: Text
    var
        actionContext: WebServiceActionContext;
        VicinityBCGenJournalMgmt: Codeunit "Vicinity BC Gen Journal Mgmt";
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");

        VicinityBCGenJournalMgmt.SetGenJournalParameters(postingdate, documentno, glaccountno, glbalaccountno, amount, batchnumber, facilityid, lineid, eventid, post, Rec);
        if VicinityBCGenJournalMgmt.Run() = true then begin
            if post then
                exit('Posted')
            else
                exit('Inserted');
        end else begin
            exit('Error: ' + GetLastErrorText);
        end;

        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure InsertItemJournal(postingdate: Date; documentno: Text; itemno: Text; locationcode: Text; bincode: Text; uomcode: Text; lotno: Text; qty: Decimal; amount: Decimal; batchnumber: Text; facilityid: Text; lineid: integer; eventid: Integer; post: Boolean) Output: Text
    var
        actionContext: WebServiceActionContext;
        VicinityBCItemJournalMgmt: Codeunit "Vicinity BC Item Journal Mgmt";
        ItemRegister: Record "Item Register";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Vicinity Setup");
        actionContext.AddEntityKey(Rec.FieldNo("Primary Key"), Rec."Primary Key");

        SourceCodeSetup.Get();
        VicinityBCItemJournalMgmt.SetItemJournalParameters(postingdate, documentno, itemno, locationcode, bincode, uomcode, lotno, qty, amount, batchnumber, facilityid, lineid, eventid, post, Rec, SourceCodeSetup);
        if VicinityBCItemJournalMgmt.Run() = true then begin
            if post then begin
                ItemRegister.Reset();
                ItemRegister.SetRange("Source Code", SourceCodeSetup."Item Journal");
                ItemRegister.SetRange("Journal Batch Name", Rec."Item Journal Batch");
                ItemRegister.SetRange("User ID", UserId);
                ItemRegister.FindLast();
                exit(format(ItemRegister."No."));
            end else
                exit('Inserted');
        end else begin
            exit('Error: ' + GetLastErrorText);
        end;

        actionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}