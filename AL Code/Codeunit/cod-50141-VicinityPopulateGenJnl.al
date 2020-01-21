codeunit 50141 "Vicinity Populate General Jnl"
{
    // version VICINITY90

    TableNo = 81;

    trigger OnRun()
    begin
        GenJournalLine.COPY(Rec);
        PopulateGenJournalLine(Rec);
        Rec := GenJournalLine;
    end;

    var
        VicinitySetup: Record "Vicinity Setup";
        TempDocNo: Text[30];
        TempWhseDocNo: Text[30];
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        VicinityErrorLog: Record "Vicinity Error Log";
        GenJournalLine: Record "Gen. Journal Line";

    procedure StartFirstGenJournalLine(pBatchNumber: Text[20]; pFacilityID: Text[15]; pPostingDate: Text[10]; var pDocumentNo: Code[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinitySetup: Record "Vicinity Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        PostingDate: Date;
        iMonth: Integer;
        iDay: Integer;
        iYear: Integer;
    begin
        ProcessedOK := TRUE;
        pErrorText := '';
        pErrorLocation := '';

        IF NOT VicinitySetup.GET THEN BEGIN
            ProcessedOK := FALSE;
            pErrorText := 'Vicinity Setup record does not exist';
        END ELSE
            IF (NOT VicinitySetup."Vicinity Enabled") THEN BEGIN
                ProcessedOK := FALSE;
                pErrorText := 'Vicinity Enabled must be True in Vicinity Setup table.';
            END ELSE
                IF (VicinitySetup."Gen. Journal Batch" = '') THEN BEGIN
                    ProcessedOK := FALSE;
                    pErrorText := 'Default Gen. Journal Batch must not be blank in Vicinity Setup table';
                END ELSE
                    IF (NOT GenJournalBatch.GET('GENERAL', VicinitySetup."Gen. Journal Batch")) THEN BEGIN
                        ProcessedOK := FALSE;
                        pErrorText := 'Gen. Journal Batch ' + VicinitySetup."Gen. Journal Batch" + ' does not exist';
                    END ELSE
                        IF (GenJournalBatch."No. Series" = '') THEN BEGIN
                            ProcessedOK := FALSE;
                            pErrorText := 'The No. Series is not defined in Gen. Journal Batch ' + GenJournalBatch.Name;
                        END;

        IF NOT ProcessedOK THEN BEGIN
            pErrorLocation := 'Vicinity Populate Journal codeunit';
        END ELSE BEGIN
            ProcessedOK := FALSE;
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            IF NOT GenJournalLine.ISEMPTY THEN BEGIN
                GenJournalLine.DELETEALL;
            END;

            IF pDocumentNo = '' THEN BEGIN
                pDocumentNo := NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series", TODAY, FALSE);
            END;

            IF STRLEN(pPostingDate) > 0 THEN BEGIN
                EVALUATE(iDay, COPYSTR(pPostingDate, 4, 2));
                EVALUATE(iMonth, COPYSTR(pPostingDate, 1, 2));
                EVALUATE(iYear, COPYSTR(pPostingDate, 7, 4));
                PostingDate := DMY2DATE(iDay, iMonth, iYear);
            END;

            IF PostingDate = 0D THEN BEGIN
                PostingDate := WORKDATE;
            END;

            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := VicinitySetup."Gen. Journal Batch";
            GenJournalLine."Line No." := 10000;
            GenJournalLine."Posting Date" := PostingDate;
            GenJournalLine."Document Date" := PostingDate;
            GenJournalLine."Source Code" := 'GENJNL';
            GenJournalLine."Source No." := 'VICINITY';
            GenJournalLine."Document No." := pDocumentNo;
            GenJournalLine."Gen. Bus. Posting Group" := VicinitySetup."Gen. Bus. Posting Group";
            GenJournalLine."Vicinity Batch No." := pBatchNumber;
            GenJournalLine."Vicinity Facility ID" := pFacilityID;
            GenJournalLine."Called From Vicinity" := TRUE;  //VICINITY - 5/30/19
            GenJournalLine.INSERT;

            ProcessedOK := TRUE;

        END; // IF
    end;

    procedure PopulateGenJournalLine(pGenJournalLine: Record "Gen. Journal Line")
    var
        NewGenJournalLine: Record "Gen. Journal Line";
        LastGenJournalLine: Record "Gen. Journal Line";
        PostJnl: Codeunit "Gen. Jnl.-Post Batch";
        LastLineNo: Integer;
    begin
        //This works with the General Journal

        SetupStandardGenJournalFields(NewGenJournalLine);
        NewGenJournalLine."Vicinity Line ID No." := pGenJournalLine."Vicinity Line ID No.";
        NewGenJournalLine."Vicinity Event ID No." := pGenJournalLine."Vicinity Event ID No.";
        SaveVicinityErrorLogInfo(NewGenJournalLine, 'Populate Journal');

        NewGenJournalLine.VALIDATE("Account No.", pGenJournalLine."Account No.");
        NewGenJournalLine.VALIDATE(Amount, pGenJournalLine.Amount);

        IF pGenJournalLine."Bal. Account No." <> '' THEN BEGIN
            NewGenJournalLine.VALIDATE("Bal. Account No.", pGenJournalLine."Bal. Account No.");
        END;

        NewGenJournalLine."Called From Vicinity" := TRUE;  //VICINITY - 5/30/19

        //after fields are set insert the line
        NewGenJournalLine.INSERT;

        // Customer Specific Code
        // Note - The parameters pCustom1, pCustom2, pCustom3 and pCustom4 are intended to be used to pass customer specific information
        //        to this function.

        // Here is an example of the code to use if pCustom1 is used to pass in the Global Dimension 1 Code for the Gen Journal Line.

        //NewGenJournalLine.VALIDATE("Shortcut Dimension 1 Code",pCustom1);
        //NewGenJournalLine.MODIFY;

        // End of Customer Specific Code
    end;

    procedure PostGenJournalBatch(var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineTemp: Record "Gen. Journal Line";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinityErrorLogT: Record "Vicinity Error Log";
        PostJnl: Codeunit "Gen. Jnl.-Post Batch";
    begin
        ProcessedOK := FALSE;
        pErrorText := '';
        pErrorLocation := '';
        IF VicinitySetup.GET THEN BEGIN
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            GenJournalLine.FINDSET;

            //PostJnl.SetCalledFromVicinity(TRUE);//Setting per line not in batch Vicinity

            IF PostJnl.RUN(GenJournalLine) THEN BEGIN
                ProcessedOK := TRUE;
            END ELSE BEGIN
                IF NOT VicinityErrorLogT.FINDLAST THEN;
                VicinityErrorLog."Entry No." := VicinityErrorLogT."Entry No." + 1;
                VicinityErrorLog."Error Text" := GETLASTERRORTEXT;
                VicinityErrorLog."Error Date" := TODAY;
                VicinityErrorLog."Error Time" := TIME;
                VicinityErrorLog.INSERT;
                ProcessedOK := FALSE;
                pErrorText := VicinityErrorLog."Error Text";
                pErrorLocation := VicinityErrorLog."Error Location";
            END;
            //PostJnl.SetCalledFromVicinity(FALSE);//Setting per line not in batch Vicinity
        END; // if
    end;

    procedure SaveVicinityErrorLogInfo(pGenJournalLine: Record "Gen. Journal Line"; pErrorLocation: Text[50])
    begin
        VicinityErrorLog.INIT;
        VicinityErrorLog."Batch No." := pGenJournalLine."Vicinity Batch No.";
        VicinityErrorLog."Facility Id" := pGenJournalLine."Vicinity Facility ID";
        VicinityErrorLog."Line ID No." := pGenJournalLine."Vicinity Line ID No.";
        VicinityErrorLog."Event ID No." := pGenJournalLine."Vicinity Event ID No.";
        VicinityErrorLog."Error Location" := pErrorLocation;
    end;

    procedure ReturnVicinityErrorLogInfo(var pVicinityErrorLog: Record "Vicinity Error Log")
    begin
        // This function is called by the "Vicinity Request Handler" codeunit.  It passes
        // the error log information from the latest Vicinity Request back to that codeunit.

        pVicinityErrorLog := VicinityErrorLog;
    end;

    procedure GetDocumentNos(var pDocNo: Text[30]; var pWhseDocNo: Text[30])
    begin
        // This function is used to pass the Item Journal, General Journal and Warehouse Journal Document Numbers back to
        // the "Vicinity Request Handler" Codeunit.

        pDocNo := TempDocNo;
        pWhseDocNo := TempWhseDocNo;
    end;

    procedure SetupStandardGenJournalFields(var pGenJournalLine: Record "Gen. Journal Line")
    var
        VicinitySetup: Record "Vicinity Setup";
        LastGenJournalLine: Record "Gen. Journal Line";
    begin
        IF VicinitySetup.GET THEN BEGIN
            LastGenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            LastGenJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Gen. Journal Batch");
            LastGenJournalLine.FINDLAST;

            pGenJournalLine."Journal Template Name" := LastGenJournalLine."Journal Template Name";
            pGenJournalLine."Journal Batch Name" := LastGenJournalLine."Journal Batch Name";
            pGenJournalLine."Line No." := LastGenJournalLine."Line No." + 10000;
            pGenJournalLine."Posting Date" := LastGenJournalLine."Posting Date";
            pGenJournalLine."Document Date" := LastGenJournalLine."Document Date";
            pGenJournalLine."Source No." := LastGenJournalLine."Source No.";
            pGenJournalLine."Source Code" := 'GENJNL';
            pGenJournalLine."Document No." := LastGenJournalLine."Document No.";
            pGenJournalLine."Vicinity Batch No." := LastGenJournalLine."Vicinity Batch No.";
            pGenJournalLine."Vicinity Facility ID" := LastGenJournalLine."Vicinity Facility ID";
        END; //if
    end;
}

