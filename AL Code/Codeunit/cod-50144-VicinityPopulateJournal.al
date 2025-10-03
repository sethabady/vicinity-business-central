codeunit 50144 "Vicinity Populate Journal"
{
    // version VICINITY90

    TableNo = 83;

    trigger OnRun()
    begin
        ItemJnlLine.COPY(Rec);
        PopulateItemJournalLine(Rec);
        Rec := ItemJnlLine;
    end;

    var
        VicinitySetup: Record "Vicinity Setup";
        TempDocNo: Text[30];
        TempWhseDocNo: Text[30];
        NoSeriesMgt: Codeunit "No. Series";
        VicinityErrorLog: Record "Vicinity Error Log";
        ItemJnlLine: Record "Item Journal Line";

    procedure StartFirstItemJournalLine(pBatchNumber: Text[20]; pFacilityID: Text[15]; pPostingDate: Text[10]; var pDocumentNo: Code[20]; var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinitySetup: Record "Vicinity Setup";
        ItemJournalBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit "No. Series";
        SourceCodeSetup: Record "Source Code Setup";
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
                IF (VicinitySetup."Item Journal Batch" = '') THEN BEGIN
                    ProcessedOK := FALSE;
                    pErrorText := 'Default Item Journal Batch must not be blank in Vicinity Setup table';
                END ELSE
                    IF (NOT ItemJournalBatch.GET('ITEM', VicinitySetup."Item Journal Batch")) THEN BEGIN
                        ProcessedOK := FALSE;
                        pErrorText := 'Item Journal Batch ' + VicinitySetup."Item Journal Batch" + ' does not exist';
                    END ELSE
                        IF (ItemJournalBatch."No. Series" = '') THEN BEGIN
                            ProcessedOK := FALSE;
                            pErrorText := 'The No. Series is not defined in Item Journal Batch ' + ItemJournalBatch.Name;
                        END;

        IF NOT ProcessedOK THEN BEGIN
            pErrorLocation := 'Vicinity Populate Journal codeunit';
        END ELSE BEGIN
            ProcessedOK := FALSE;
            ItemJournalLine.RESET;
            ItemJournalLine.SETRANGE("Journal Template Name", 'ITEM');
            ItemJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Item Journal Batch");
            IF NOT ItemJournalLine.ISEMPTY THEN BEGIN
                ItemJournalLine.DELETEALL;
            END;

            ReservationEntry.RESET;
            ReservationEntry.SETRANGE("Source Type", 83);
            ReservationEntry.SETRANGE("Source ID", 'ITEM');
            ReservationEntry.SETRANGE("Source Batch Name", VicinitySetup."Item Journal Batch");
            IF NOT ReservationEntry.ISEMPTY THEN BEGIN
                ReservationEntry.DELETEALL;
            END;

            IF pDocumentNo = '' THEN BEGIN
                pDocumentNo := NoSeriesMgt.PeekNextNo(ItemJournalBatch."No. Series", TODAY);
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

            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Item Journal");

            ItemJournalLine.INIT;
            ItemJournalLine."Journal Template Name" := 'ITEM';
            ItemJournalLine."Journal Batch Name" := VicinitySetup."Item Journal Batch";
            ItemJournalLine."Line No." := 10000;
            ItemJournalLine."Posting Date" := PostingDate;
            ItemJournalLine."Document Date" := PostingDate;
            ItemJournalLine."Source No." := 'VICINITY';
            ItemJournalLine."Document No." := pDocumentNo;
            ItemJournalLine."Gen. Bus. Posting Group" := VicinitySetup."Gen. Bus. Posting Group";
            ItemJournalLine."Vicinity Batch No." := pBatchNumber;
            ItemJournalLine."Vicinity Facility ID" := pFacilityID;
            ItemJournalLine."Called From Vicinity" := TRUE;  //VICINITY - 5/30/19
            ItemJournalLine."Source Code" := SourceCodeSetup."Item Journal"; //VICINITY - 6/13/19
            ItemJournalLine.INSERT;

            ProcessedOK := TRUE;

        END; // IF
    end;

    procedure PopulateItemJournalLine(pItemJournalLine: Record "Item Journal Line")
    var
        NewItemJournalLine: Record "Item Journal Line";
        LastItemJournalLine: Record "Item Journal Line";
        PostJnl: Codeunit "Item Jnl.-Post Batch";
        ResvEntry: Record "Reservation Entry";
        ResvEntryTemp: Record "Reservation Entry";
        LastLineNo: Integer;
        ItemRec: Record "Item";
        ITCRec: Record "Item Tracking Code";
    begin
        //This works with the Item Journal

        SetupStandardItemJournalFields(NewItemJournalLine);
        NewItemJournalLine."Vicinity Line ID No." := pItemJournalLine."Vicinity Line ID No.";
        NewItemJournalLine."Vicinity Event ID No." := pItemJournalLine."Vicinity Event ID No.";
        NewItemJournalLine."Called From Vicinity" := TRUE;   //Vicinity - 5/30/19
        SaveVicinityErrorLogInfo(NewItemJournalLine, 'Populate Journal');

        NewItemJournalLine.VALIDATE("Item No.", pItemJournalLine."Item No.");

        NewItemJournalLine.VALIDATE("Location Code", pItemJournalLine."Location Code");
        NewItemJournalLine.VALIDATE("Bin Code", pItemJournalLine."Bin Code");
        NewItemJournalLine.VALIDATE("Unit of Measure Code", pItemJournalLine."Unit of Measure Code");
        NewItemJournalLine.Quantity := pItemJournalLine.Quantity;
        IF NewItemJournalLine.Quantity > 0 THEN BEGIN
            NewItemJournalLine."Entry Type" := NewItemJournalLine."Entry Type"::"Positive Adjmt.";
            NewItemJournalLine.VALIDATE(Quantity);
            NewItemJournalLine.Amount := pItemJournalLine.Amount;
            NewItemJournalLine.VALIDATE(Amount);
        END ELSE BEGIN
            NewItemJournalLine.Quantity := -NewItemJournalLine.Quantity;
            NewItemJournalLine."Entry Type" := NewItemJournalLine."Entry Type"::"Negative Adjmt.";
            NewItemJournalLine.VALIDATE(Quantity);
        END;

        // V4-2009
        NewItemJournalLine."Applies-to Entry" := pItemJournalLine."Applies-to Entry";

        // Lot Tracking
        IF pItemJournalLine."Lot No." <> '' THEN BEGIN
            IF ItemRec.GET(NewItemJournalLine."Item No.") THEN BEGIN
                IF ITCRec.GET(ItemRec."Item Tracking Code") THEN
                    IF ITCRec."Lot Specific Tracking" THEN BEGIN
                        //set reservation entry which does the lot entries
                        ResvEntry.INIT;
                        CLEAR(ResvEntryTemp);
                        IF ResvEntryTemp.FIND('+') THEN BEGIN
                            ResvEntry."Entry No." := ResvEntryTemp."Entry No." + 1
                        END ELSE BEGIN
                            ResvEntry."Entry No." := 1;
                        END;
                        ResvEntry."Item No." := NewItemJournalLine."Item No.";
                        ResvEntry."Location Code" := NewItemJournalLine."Location Code";
                        ResvEntry."Lot No." := pItemJournalLine."Lot No.";
                        ResvEntry."Reservation Status" := ResvEntry."Reservation Status"::Prospect;
                        ResvEntry."Creation Date" := NewItemJournalLine."Posting Date";
                        ResvEntry."Source Type" := 83;
                        ResvEntry."Source ID" := NewItemJournalLine."Journal Template Name";
                        ResvEntry."Source Batch Name" := NewItemJournalLine."Journal Batch Name";
                        ResvEntry."Source Ref. No." := NewItemJournalLine."Line No.";
                        IF NewItemJournalLine."Entry Type" = NewItemJournalLine."Entry Type"::"Positive Adjmt." THEN BEGIN
                            ResvEntry.Positive := TRUE;
                            ResvEntry.Quantity := NewItemJournalLine.Quantity;
                            ResvEntry."Quantity (Base)" := NewItemJournalLine."Quantity (Base)";
                            ResvEntry."Source Subtype" := 2;
                            ResvEntry."Expected Receipt Date" := NewItemJournalLine."Posting Date";
                        END ELSE BEGIN
                            ResvEntry.Quantity := -NewItemJournalLine.Quantity;
                            ResvEntry."Quantity (Base)" := -NewItemJournalLine."Quantity (Base)";
                            ResvEntry."Source Subtype" := 3;
                            ResvEntry."Shipment Date" := NewItemJournalLine."Posting Date";
                        END;
                        ResvEntry."Qty. per Unit of Measure" := NewItemJournalLine."Qty. per Unit of Measure";
                        ResvEntry."Qty. to Handle (Base)" := ResvEntry."Quantity (Base)";
                        ResvEntry."Qty. to Invoice (Base)" := ResvEntry."Quantity (Base)";
                        ResvEntry.INSERT;
                    END;
            END;
        END;

        //after fields are set insert the line
        NewItemJournalLine.INSERT;


        // Customer Specific Code
        // Note - The parameters pCustom1, pCustom2, pCustom3 and pCustom4 are intended to be used to pass customer specific information
        //        to this function.

        // Here is an example of the code to use if pCustom1 is used to pass in the Global Dimension 1 Code for the Item Journal Line.

        //NewItemJournalLine.VALIDATE("Shortcut Dimension 1 Code",pCustom1);
        //NewItemJournalLine.MODIFY;

        // End of Customer Specific Code
    end;

    procedure PostItemJournalBatch(var ProcessedOK: Boolean; var pErrorText: Text[250]; var pErrorLocation: Text[50])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineTemp: Record "Item Journal Line";
        VicinityErrorLog: Record "Vicinity Error Log";
        VicinityErrorLogT: Record "Vicinity Error Log";
        PostJnl: Codeunit "Item Jnl.-Post Batch";
    begin
        ProcessedOK := FALSE;
        pErrorText := '';
        pErrorLocation := '';
        IF VicinitySetup.GET THEN BEGIN
            ItemJournalLine.RESET;
            ItemJournalLine.SETRANGE("Journal Template Name", 'ITEM');
            ItemJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Item Journal Batch");
            ItemJournalLine.FINDSET;

            //if vicinity setup uses warehousing then setup and post whse journal before posting
            //IF VicinitySetup."Warehousing Enabled" THEN BEGIN
            //  ItemJournalLine.FINDFIRST;
            //  PopulateWhseJournal(ItemJournalLine."Location Code");
            //END;

            //PostJnl.SetCalledFromVicinity(TRUE);  //Vicinity move code
            IF PostJnl.RUN(ItemJournalLine) THEN BEGIN
                ProcessedOK := TRUE;
            END ELSE BEGIN
                //PostJnl.ReturnVicinityErrorLogInfo(VicinityErrorLog);
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
            //PostJnl.SetCalledFromVicinity(FALSE);  //Vicinity Move code
        END; // if
    end;

    procedure PopulateWhseJournal(LocCode: Text[30])
    var
        WIJLRecTemp: Record "Warehouse Journal Line";
        WIJLRecPop: Record "Warehouse Journal Line";
        //XMLNodeFound: Automation; //Is below line correct?
        //XMLNodeFound: XmlNode;
        i: Integer;
        //XMLLineNode: Automation;  //Is below line correct?
        //XMLLineNode: XmlNode;
        //XMLNodeFoundRoot: Automation;//Is below line correct?
        //XMLNodeFoundRoot: XmlNode;
        TempPath: Text[30];
        WJnlBatch: Record "Warehouse Journal Batch";
        AnotherNode: Boolean;
        PostWJnl: Codeunit "Whse. Jnl.-Register Batch";
        ItemJournalTemp: Record "Item Journal Line";
        LocRec: Record "Location";
        Bin: Record "Bin";
        ResvEntry: Record "Reservation Entry";
        WhseTrackEntry: Record "Whse. Item Tracking Line";
        WhseTrackEntryTemp: Record "Whse. Item Tracking Line";
        LastLineNo: Integer;
    begin
        //  NOTE: This function has not been tested.

        IF VicinitySetup.GET THEN BEGIN
            LocRec.GET(LocCode);
            WIJLRecTemp.SETRANGE("Journal Template Name", 'ADJMT');
            WIJLRecTemp.SETRANGE("Journal Batch Name", VicinitySetup."Warehouse Journal Batch");
            WIJLRecTemp.SETRANGE("Location Code", LocCode);

            //clear journal if populated. Repopulate from Item journal
            IF NOT WIJLRecTemp.ISEMPTY THEN BEGIN
                WIJLRecTemp.DELETEALL;
            END;

            //clear reservation entries for lots or serial numbers
            WhseTrackEntryTemp.SETRANGE("Source ID", 'ADJMT');
            WhseTrackEntryTemp.SETRANGE("Source Batch Name", VicinitySetup."Warehouse Journal Batch");
            IF NOT WhseTrackEntryTemp.ISEMPTY THEN BEGIN
                WhseTrackEntryTemp.DELETEALL;
            END;

            //get item journal and loop through lines to create whse item jnl lines
            ItemJournalTemp.SETRANGE("Journal Template Name", 'ITEM');
            ItemJournalTemp.SETRANGE("Journal Batch Name", VicinitySetup."Item Journal Batch");
            IF ItemJournalTemp.FINDSET THEN BEGIN
                REPEAT

                    SaveVicinityErrorLogInfo(ItemJournalTemp, 'Populate Warehouse Journal');
                    WIJLRecPop."Journal Template Name" := 'ADJMT';
                    WIJLRecPop."Journal Batch Name" := VicinitySetup."Warehouse Journal Batch";

                    //set document number and line from item journal
                    WIJLRecPop."Whse. Document No." := ItemJournalTemp."Document No.";
                    WIJLRecPop."Line No." := ItemJournalTemp."Line No.";

                    WIJLRecPop."Location Code" := LocCode;
                    WIJLRecPop."Registering Date" := ItemJournalTemp."Posting Date";
                    WIJLRecPop."Entry Type" := ItemJournalTemp."Entry Type".AsInteger();
                    WIJLRecPop.VALIDATE("Item No.", ItemJournalTemp."Item No.");
                    WIJLRecPop.VALIDATE("Unit of Measure Code", ItemJournalTemp."Unit of Measure Code");
                    WIJLRecPop.VALIDATE(Quantity, ItemJournalTemp.Quantity);
                    IF WIJLRecPop.Quantity < 0 THEN BEGIN
                        WIJLRecPop.VALIDATE("Bin Code", LocRec."To-Production Bin Code");
                    END ELSE BEGIN
                        WIJLRecPop.VALIDATE("Bin Code", LocRec."From-Production Bin Code");
                        WIJLRecPop."From Bin Code" := LocRec."Adjustment Bin Code";
                        Bin.GET(LocCode, LocRec."Adjustment Bin Code");
                        WIJLRecPop."From Zone Code" := Bin."Zone Code";
                    END;

                    //get reservation entry which does the lot entries for item journal and create whse tracking
                    ResvEntry.SETRANGE("Source ID", 'ITEM');
                    ResvEntry.SETRANGE("Source Batch Name", VicinitySetup."Item Journal Batch");
                    ResvEntry.SETRANGE("Source Ref. No.", ItemJournalTemp."Line No.");
                    IF ResvEntry.FINDFIRST THEN BEGIN
                        WhseTrackEntry.INIT;
                        CLEAR(WhseTrackEntryTemp);
                        IF WhseTrackEntryTemp.FINDLAST THEN BEGIN
                            WhseTrackEntry."Entry No." := WhseTrackEntryTemp."Entry No." + 1
                        END ELSE BEGIN
                            WhseTrackEntry."Entry No." := 1;
                        END;
                        WhseTrackEntry."Item No." := ResvEntry."Item No.";
                        WhseTrackEntry."Location Code" := ResvEntry."Location Code";
                        WhseTrackEntry."Quantity (Base)" := ABS(ResvEntry."Quantity (Base)");
                        WhseTrackEntry."Source Type" := 7311;
                        WhseTrackEntry."Source Subtype" := 0;
                        WhseTrackEntry."Source ID" := WIJLRecTemp.GETFILTER("Journal Batch Name");
                        WhseTrackEntry."Source Batch Name" := WIJLRecTemp.GETFILTER("Journal Template Name");
                        WhseTrackEntry."Source Ref. No." := WIJLRecPop."Line No.";
                        WhseTrackEntry."Qty. to Handle (Base)" := ABS(ResvEntry."Quantity (Base)");
                        WhseTrackEntry."Qty. to Handle" := ABS(WhseTrackEntry."Qty. to Handle (Base)");
                        WhseTrackEntry."Lot No." := ResvEntry."Lot No.";
                        WhseTrackEntry."Serial No." := ResvEntry."Serial No.";
                        WhseTrackEntry.INSERT;
                    END;

                    WIJLRecPop.INSERT;
                UNTIL ItemJournalTemp.NEXT = 0;
            END; // IF

            //  PostWJnl.VicinityRun(WIJLRecPop,TRUE);
        END; // if
    end;

    procedure SaveVicinityErrorLogInfo(pItemJournal: Record "Item Journal Line"; pErrorLocation: Text[50])
    begin
        VicinityErrorLog.INIT;
        VicinityErrorLog."Batch No." := pItemJournal."Vicinity Batch No.";
        VicinityErrorLog."Facility Id" := pItemJournal."Vicinity Facility ID";
        VicinityErrorLog."Line ID No." := pItemJournal."Vicinity Line ID No.";
        VicinityErrorLog."Event ID No." := pItemJournal."Vicinity Event ID No.";
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
        // This function is used to pass the Item Journal and Warehouse Journal Document Numbers back to
        // the "Vicinity Request Handler" Codeunit.

        pDocNo := TempDocNo;
        pWhseDocNo := TempWhseDocNo;
    end;

    procedure SetupStandardItemJournalFields(var pItemJournalLine: Record "Item Journal Line")
    var
        VicinitySetup: Record "Vicinity Setup";
        LastItemJournalLine: Record "Item Journal Line";
    begin
        IF VicinitySetup.GET THEN BEGIN
            LastItemJournalLine.SETRANGE("Journal Template Name", 'ITEM');
            LastItemJournalLine.SETRANGE("Journal Batch Name", VicinitySetup."Item Journal Batch");
            LastItemJournalLine.FINDLAST;
            pItemJournalLine."Journal Template Name" := LastItemJournalLine."Journal Template Name";
            pItemJournalLine."Journal Batch Name" := LastItemJournalLine."Journal Batch Name";
            pItemJournalLine."Line No." := LastItemJournalLine."Line No." + 10000;
            pItemJournalLine."Posting Date" := LastItemJournalLine."Posting Date";
            pItemJournalLine."Document Date" := LastItemJournalLine."Document Date";
            pItemJournalLine."Source No." := LastItemJournalLine."Source No.";
            pItemJournalLine."Source Code" := LastItemJournalLine."Source Code";
            pItemJournalLine."Document No." := LastItemJournalLine."Document No.";
            pItemJournalLine."Gen. Bus. Posting Group" := LastItemJournalLine."Gen. Bus. Posting Group";
            pItemJournalLine."Vicinity Batch No." := LastItemJournalLine."Vicinity Batch No.";
            pItemJournalLine."Vicinity Facility ID" := LastItemJournalLine."Vicinity Facility ID";
        END; //if
    end;
}

