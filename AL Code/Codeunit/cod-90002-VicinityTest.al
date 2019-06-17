codeunit 90002 "Vicinity Test Codeunit"
{
    // version VICINITY90,Optional

    // NOTE: This codeunit illustrates the use of the three Vicinity Manufacturing - Dynamics NAV 2015 Link functions.
    // It is hard coded with data from the Cronus company in the Dynamics NAV 2013 demo database.
    // It can be used for testing the link if needed.


    trigger OnRun()
    begin
        //TestItemJournalFunctions;
        SetupVicinity;
        TestItemJournalFunctions;
        //TestGenJournalFunctions1;
        MESSAGE('Done');
    end;

    var
        VicinityWebService: Codeunit "Vicinity Web Service";
        BatchNumber: Text[20];
        FacilityID: Text[15];
        PostingDate: Text[10];
        DocumentNo: Code[20];
        ProcessedOK: Boolean;
        ErrorText: Text[250];
        ErrorLocation: Text[50];
        "--V2--": Integer;
        LineIDNumber: Integer;
        EventIDNumber: Integer;
        AccountNo: Text[20];
        ItemNo: Text[20];
        LocationCode: Text[20];
        UnitOfMeasureCode: Text[20];
        Quantity: Decimal;
        Amount: Decimal;
        LotNo: Text[10];
        //WebService: Record "Web Service";

    procedure SetupVicinity()
    var
        VicinitySetup: Record "Vicinity Setup";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
        GenJournalBatch: Record "Gen. Journal Batch";
        ItemJournalBatch: Record "Item Journal Batch";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        IF NOT VicinitySetup.FINDFIRST THEN BEGIN
            VicinitySetup."Vicinity Enabled" := TRUE;
            VicinitySetup."Item Journal Batch" := 'VICINITY';
            VicinitySetup."Gen. Bus. Posting Group" := 'VIC';
            VicinitySetup."Gen. Journal Batch" := 'VICINITY';
            VicinitySetup.INSERT;
        END;

        IF NOT GenBusinessPostingGroup.GET('VIC') THEN BEGIN
            GenBusinessPostingGroup.Code := 'VIC';
            GenBusinessPostingGroup.Description := 'Vicinity Manufacturing';
            GenBusinessPostingGroup."Auto Insert Default" := TRUE;
            GenBusinessPostingGroup.INSERT;
        END;

        IF NOT GeneralPostingSetup.GET('VIC', 'RETAIL') THEN BEGIN
            IF GenProdPostingGroup.GET('RETAIL') THEN BEGIN
                GeneralPostingSetup."Gen. Bus. Posting Group" := 'VIC';
                GeneralPostingSetup."Gen. Prod. Posting Group" := 'RETAIL';
                GeneralPostingSetup."Sales Account" := '44200';
                GeneralPostingSetup."Sales Credit Memo Account" := '44200';
                GeneralPostingSetup."Sales Line Disc. Account" := '45200';
                GeneralPostingSetup."Sales Inv. Disc. Account" := '45200';
                GeneralPostingSetup."Purch. Account" := '54100';
                GeneralPostingSetup."Purch. Credit Memo Account" := '54100';
                GeneralPostingSetup."Purch. Line Disc. Account" := '54400';
                GeneralPostingSetup."Purch. Inv. Disc. Account" := '54400';
                GeneralPostingSetup."COGS Account" := '54700';
                GeneralPostingSetup."Inventory Adjmt. Account" := '54500';
                GeneralPostingSetup.INSERT
            END;
        END;

        IF NOT GenJournalBatch.GET('GENERAL', 'VICINITY') THEN BEGIN
            GenJournalBatch."Journal Template Name" := 'GENERAL';
            GenJournalBatch.Name := 'VICINITY';
            GenJournalBatch.Description := 'Batch for Posting Vicinity';
            GenJournalBatch."No. Series" := 'GJNL-VIC';
            GenJournalBatch."Copy VAT Setup to Jnl. Lines" := TRUE;
            GenJournalBatch.INSERT;
        END;

        IF NOT ItemJournalBatch.GET('ITEM', 'VICINITY') THEN BEGIN
            ItemJournalBatch."Journal Template Name" := 'ITEM';
            ItemJournalBatch.Name := 'VICINITY';
            ItemJournalBatch.Description := 'Batch for Posting Vicinity';
            ItemJournalBatch."No. Series" := 'VICINITY';
            ItemJournalBatch.INSERT;
        END;

        IF NOT NoSeries.GET('VICINITY') THEN BEGIN
            NoSeries.Code := 'VICINITY';
            NoSeries.Description := 'Vicinity';
            NoSeries.INSERT;
        END;

        NoSeriesLine.SETRANGE("Series Code", 'VICINITY');
        IF NOT NoSeriesLine.FINDFIRST THEN BEGIN
            NoSeriesLine."Series Code" := 'VICINITY';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 20010114D;
            NoSeriesLine."Starting No." := 'VIC000001';
            NoSeriesLine."Ending No." := 'VIC999999';
            NoSeriesLine.INSERT;
        END;

        IF NOT NoSeries.GET('GJNL-VIC') THEN BEGIN
            NoSeries.Code := 'GJNL-VIC';
            NoSeries.Description := 'GJNL-VIC';
            NoSeries.INSERT;
        END;


        NoSeriesLine.SETRANGE("Series Code", 'GJNL-VIC');
        IF NOT NoSeriesLine.FINDFIRST THEN BEGIN
            NoSeriesLine."Series Code" := 'GJNL-VIC';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := 20010114D;
            NoSeriesLine."Starting No." := 'VICG000001';
            NoSeriesLine."Ending No." := 'VICG999999';
            NoSeriesLine.INSERT;
        END;

        //IF NOT WebService.GET(WebService."Object Type"::Codeunit, 'VicinityWebService') THEN BEGIN
        //    WebService."Object Type" := WebService."Object Type"::Codeunit;
        //    WebService."Service Name" := 'VicinityWebService';
        //    WebService."Object ID" := 50098;
        //   WebService.Published := TRUE;
        //    WebService.INSERT;
        //END;
    end;

    procedure TestItemJournalFunctions()
    var
        BinCode: Text[20];
        Custom1: Text[20];
        Custom2: Text[20];
        Custom3: Text[20];
        Custom4: Text[20];
    begin
        BatchNumber := 'BATCH1';
        FacilityID := 'VICINITY';
        PostingDate := '01/02/2014';
        VicinityWebService.StartNewItemJournalBatch(BatchNumber, FacilityID, PostingDate, DocumentNo, ProcessedOK, ErrorText, ErrorLocation);
        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        ItemNo := '80216-T';
        LocationCode := 'SILVER';
        UnitOfMeasureCode := 'PCS';
        Quantity := -100;
        Amount := 45;
        LotNo := 'LOT124';
        BinCode := 'S-01-0001';
        Custom1 := '';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';

        VicinityWebService.WriteItemJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(ItemNo), UPPERCASE(LocationCode),
          UPPERCASE(UnitOfMeasureCode), Quantity, Amount, UPPERCASE(LotNo),
          Custom1, BinCode, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        ItemNo := '1964-w';
        LocationCode := 'SILVER';
        UnitOfMeasureCode := 'pcs';
        Quantity := 123.12;
        Amount := 45;
        LotNo := 'lot001';
        BinCode := 'S-01-0001';
        Custom1 := '';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';

        VicinityWebService.WriteItemJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(ItemNo), UPPERCASE(LocationCode),
          UPPERCASE(UnitOfMeasureCode), Quantity, Amount, UPPERCASE(LotNo),
          Custom1, BinCode, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        LineIDNumber := 12;
        EventIDNumber := 2;
        ItemNo := '1964-W';
        LocationCode := 'SILVER';
        UnitOfMeasureCode := 'pcs';
        Quantity := 123.12;
        Amount := 45;
        LotNo := 'lot002';
        BinCode := 'S-01-0001';
        Custom1 := '';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';

        VicinityWebService.WriteItemJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(ItemNo), UPPERCASE(LocationCode),
          UPPERCASE(UnitOfMeasureCode), Quantity, Amount, UPPERCASE(LotNo),
          Custom1, BinCode, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        VicinityWebService.PostItemJournalBatch(ProcessedOK, ErrorText, ErrorLocation);
        IF ProcessedOK THEN BEGIN
            MESSAGE('The Item Journal Lines were posted.');
        END ELSE BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;
    end;

    procedure TestGenJournalFunctions1()
    var
        Custom1: Text[20];
        Custom2: Text[20];
        Custom3: Text[20];
        Custom4: Text[20];
    begin
        BatchNumber := 'BATCH1';
        FacilityID := 'NANO';
        PostingDate := '01/07/2014';

        VicinityWebService.StartNewGenJournalBatch(BatchNumber, FacilityID, PostingDate, DocumentNo, ProcessedOK, ErrorText, ErrorLocation);
        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52410';
        Amount := 150;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52460';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52450';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '15231';
        Amount := -180;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;



        VicinityWebService.PostGenJournalBatch(ProcessedOK, ErrorText, ErrorLocation);
        IF ProcessedOK THEN BEGIN
            MESSAGE('The General Journal Lines were posted.');
        END ELSE BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;
    end;

    procedure TestGenJournalFunctions2()
    var
        Custom1: Text[20];
        Custom2: Text[20];
        Custom3: Text[20];
        Custom4: Text[20];
    begin
        BatchNumber := 'BATCH1';
        FacilityID := 'NANO';
        PostingDate := '01/07/2014';

        VicinityWebService.StartNewGenJournalBatch(BatchNumber, FacilityID, PostingDate, DocumentNo, ProcessedOK, ErrorText, ErrorLocation);
        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52410';
        Amount := 150;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52460';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52450';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '15231';
        Amount := -179;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;



        VicinityWebService.PostGenJournalBatch(ProcessedOK, ErrorText, ErrorLocation);
        IF ProcessedOK THEN BEGIN
            MESSAGE('The General Journal Lines were posted.');
        END ELSE BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;
    end;

    procedure TestGenJournalFunctions3()
    var
        Custom1: Text[20];
        Custom2: Text[20];
        Custom3: Text[20];
        Custom4: Text[20];
    begin
        BatchNumber := 'BATCH1';
        FacilityID := 'NANO';
        PostingDate := '01/07/2014';

        VicinityWebService.StartNewGenJournalBatch(BatchNumber, FacilityID, PostingDate, DocumentNo, ProcessedOK, ErrorText, ErrorLocation);
        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52410';
        Amount := 150;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '15231', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52460';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '15231', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;

        LineIDNumber := 12;
        EventIDNumber := 2;
        AccountNo := '52450';
        Amount := 15;
        Custom1 := 'test';
        Custom2 := '';
        Custom3 := '';
        Custom4 := '';
        VicinityWebService.WriteGenJournalLine(BatchNumber, FacilityID,
          LineIDNumber, EventIDNumber, UPPERCASE(AccountNo), '15231', Amount,
          Custom1, Custom2, Custom3, Custom4, ProcessedOK, ErrorText, ErrorLocation);

        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;


        IF NOT ProcessedOK THEN BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;



        VicinityWebService.PostGenJournalBatch(ProcessedOK, ErrorText, ErrorLocation);
        IF ProcessedOK THEN BEGIN
            MESSAGE('The General Journal Lines were posted.');
        END ELSE BEGIN
            ERROR(ErrorLocation + ': ' + ErrorText);
        END;
    end;
}

