codeunit 90003 "Vicinity Web Service"
{
    // version VICINITY90


    trigger OnRun()
    begin
    end;

    var
        VicinityPopulateJournal: Codeunit "Vicinity Populate Journal";
        VicinityPopulateGeneralJnl: Codeunit "Vicinity Populate General Jnl";

    procedure StartNewItemJournalBatch(pBatchNumber: Text[20]; pFacilityID: Text[15]; pPostingDate: Text[10]; var pDocumentNo: Code[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        ItemJournalLine: Record "Item Journal Line";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinitySetup: Record "Vicinity Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostingDate: Date;
        iMonth: Integer;
        iDay: Integer;
        iYear: Integer;
    begin
        VicinityPopulateJournal.StartFirstItemJournalLine(pBatchNumber, pFacilityID, pPostingDate, pDocumentNo, ProcessedOK, pErrorText, pErrorLocation);
        COMMIT;
    end;

    procedure WriteItemJournalLine(pBatchNumber: Text[20]; pFacilityID: Text[15]; pLineIDNumber: Integer; pEventIDNumber: Integer; pItemNo: Text[20]; pLocationCode: Text[10]; pUnitOfMeasureCode: Text[10]; pQuantity: Decimal; pAmount: Decimal; pLotNo: Text[20]; pCustom1: Text[20]; pCustom2: Text[20]; pCustom3: Text[20]; pCustom4: Text[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinityErrorLogT: Record "Vicinity Error Log";
        ItemJournalLineTemp: Record "Item Journal Line";
    begin
        ProcessedOK := TRUE;

        ItemJournalLineTemp.INIT;
        ItemJournalLineTemp."Vicinity Batch No." := pBatchNumber;
        ItemJournalLineTemp."Vicinity Facility ID" := pFacilityID;
        ItemJournalLineTemp."Vicinity Line ID No." := pLineIDNumber;
        ItemJournalLineTemp."Vicinity Event ID No." := pEventIDNumber;
        ItemJournalLineTemp."Item No." := UPPERCASE(pItemNo);
        ItemJournalLineTemp."Location Code" := UPPERCASE(pLocationCode);
        ItemJournalLineTemp."Bin Code" := UPPERCASE(pCustom2);
        ItemJournalLineTemp."Unit of Measure Code" := UPPERCASE(pUnitOfMeasureCode);
        ItemJournalLineTemp.Quantity := pQuantity;
        ItemJournalLineTemp.Amount := pAmount;
        ItemJournalLineTemp."Lot No." := UPPERCASE(pLotNo);

        IF NOT VicinityPopulateJournal.RUN(ItemJournalLineTemp) THEN BEGIN
            VicinityPopulateJournal.ReturnVicinityErrorLogInfo(VicinityErrorLog);
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
        COMMIT;
    end;

    procedure PostItemJournalBatch(var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    begin
        VicinityPopulateJournal.PostItemJournalBatch(ProcessedOK, pErrorText, pErrorLocation);
        COMMIT;
    end;

    procedure StartNewGenJournalBatch(pBatchNumber: Text[20]; pFacilityID: Text[15]; pPostingDate: Text[10]; var pDocumentNo: Code[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        GenJournalLine: Record "Gen. Journal Line";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinitySetup: Record "Vicinity Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostingDate: Date;
        iMonth: Integer;
        iDay: Integer;
        iYear: Integer;
    begin
        VicinityPopulateGeneralJnl.StartFirstGenJournalLine(pBatchNumber, pFacilityID, pPostingDate, pDocumentNo, ProcessedOK, pErrorText, pErrorLocation);
        COMMIT;
    end;

    procedure WriteGenJournalLine(pBatchNumber: Text[20]; pFacilityID: Text[15]; pLineIDNumber: Integer; pEventIDNumber: Integer; pAccountNo: Text[20]; pBalancingAccountNo: Text[20]; pAmount: Decimal; pCustom1: Text[20]; pCustom2: Text[20]; pCustom3: Text[20]; pCustom4: Text[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinityErrorLogT: Record "Vicinity Error Log";
        GenJournalLineTemp: Record "Gen. Journal Line";
    begin
        ProcessedOK := TRUE;

        GenJournalLineTemp.INIT;
        GenJournalLineTemp."Vicinity Batch No." := pBatchNumber;
        GenJournalLineTemp."Vicinity Facility ID" := pFacilityID;
        GenJournalLineTemp."Vicinity Line ID No." := pLineIDNumber;
        GenJournalLineTemp."Vicinity Event ID No." := pEventIDNumber;
        GenJournalLineTemp."Account No." := UPPERCASE(pAccountNo);
        GenJournalLineTemp."Bal. Account No." := UPPERCASE(pBalancingAccountNo);
        GenJournalLineTemp.Amount := pAmount;

        IF NOT VicinityPopulateGeneralJnl.RUN(GenJournalLineTemp) THEN BEGIN
            VicinityPopulateGeneralJnl.ReturnVicinityErrorLogInfo(VicinityErrorLog);
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
        COMMIT;
    end;

    procedure PostGenJournalBatch(var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    begin
        VicinityPopulateGeneralJnl.PostGenJournalBatch(ProcessedOK, pErrorText, pErrorLocation);
        COMMIT;
    end;
}

