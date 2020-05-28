codeunit 50150 "Vicinity BC Gen Journal Mgmt"
{
    trigger OnRun()
    begin
        InsertGenJournal();
    end;

    procedure SetGenJournalParameters(pPostingDate: Date; pDocumentNo: Text; pGLAccountNo: Code[20]; pGLBalAccountNo: Code[20]; pAmount: Decimal; pBatchNumber: Code[20]; pFacilityID: Code[15]; pLineID: Integer; pEventID: Integer; pFirstLine: Boolean; pPost: Boolean; pVicinitySetup: Record "Vicinity Setup")
    begin
        PostingDate := pPostingDate;
        DocumentNo := pDocumentNo;
        GLAccountNo := pGLAccountNo;
        GLBalAccountNo := pGLBalAccountNo;
        Amount := pAmount;
        BatchNumber := pBatchNumber;
        FacilityID := pFacilityID;
        LineID := pLineID;
        EventID := pEventID;
        FirstLine := pFirstLine;
        Post := pPost;
        VicinitySetup := pVicinitySetup;
    end;

    local procedure InsertGenJournal()
    begin
        VicinitySetup.TestField("Vicinity Enabled");
        VicinitySetup.TestField("Gen. Journal Batch");
        VicinitySetup.TestField("Gen. Bus. Posting Group");

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("General Journal");

        LineNo := 0;
        if FirstLine then begin
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate);
            GenJnlLine.SetRange("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            if GenJnlLine.IsEmpty = false then
                GenJnlLine.DeleteAll(true);
        end else begin
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate);
            GenJnlLine.SetRange("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            if GenJnlLine.FindLast() then
                LineNo := GenJnlLine."Line No.";
        end;

        LineNo += 10000;

        if PostingDate = 0D then
            PostingDate := WorkDate();

        if DocumentNo = '' then begin
            GenJournalBatch.Get(GenJnlTemplate, VicinitySetup."Gen. Journal Batch");
            GenJournalBatch.TestField("No. Series");
            DocumentNo := NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series", TODAY, FALSE);
        end;

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := GenJnlTemplate;
        GenJnlLine."Journal Batch Name" := VicinitySetup."Gen. Journal Batch";
        GenJnlLine."Line No." := LineNo;
        GenJnlLine.Validate("Posting Date", PostingDate);
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Account No.", GLAccountNo);
        GenJnlLine.Validate(Amount, Amount);

        IF GLBalAccountNo <> '' THEN BEGIN
            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            GenJnlLine.VALIDATE("Bal. Account No.", GLBalAccountNo);
        END;

        GenJnlLine."Gen. Bus. Posting Group" := VicinitySetup."Gen. Bus. Posting Group";
        GenJnlLine."Source Code" := SourceCodeSetup."General Journal";
        GenJnlLine."Source No." := VicinityLabel;

        GenJnlLine."Vicinity Batch No." := BatchNumber;
        GenJnlLine."Vicinity Facility ID" := FacilityID;
        GenJnlLine."Vicinity Line ID No." := LineID;
        GenJnlLine."Vicinity Event ID No." := EventID;
        GenJnlLine."Called From Vicinity" := true;
        GenJnlLine.INSERT;

        if Post then begin
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate);
            GenJnlLine.SetRange("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            GenJnlPostBatch.Run(GenJnlLine);
        end;
    end;

    var
        PostingDate: Date;
        DocumentNo: Text;
        GLAccountNo: Code[20];
        GLBalAccountNo: Code[20];
        Amount: Decimal;
        BatchNumber: Code[20];
        FacilityID: Code[15];
        LineID: Integer;
        EventID: Integer;
        Post: Boolean;
        FirstLine: Boolean;
        VicinitySetup: Record "Vicinity Setup";
        GenJnlLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJnlTemplate: Label 'GENERAL';
        VicinityLabel: Label 'VICINITY';
        LineNo: Integer;
}