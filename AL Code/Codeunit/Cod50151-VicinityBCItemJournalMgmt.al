codeunit 50151 "Vicinity BC Item Journal Mgmt"
{
    trigger OnRun()
    begin
//        InsertItemJournal();

        AddProdJournalLine(
            'CONSUMP', // Journal Template Name
            'DEFAULT', // Journal Batch Name
            '101001',   // Prod Order No
            ItemJnlLine."Entry Type"::Consumption, // Entry Type
            'VP-RM1',    // Item No
            10,         // Quantity
            'MAIN',    // Location Code
            WorkDate(),// Posting Date
            'DOC1001'  // Document No
        );
    end;

    procedure SetItemJournalParameters(pPostingDate: Date; pDocumentNo: Text; pItemNo: Code[20]; pLocationCode: Code[20]; pBinCode: Code[20]; pUoMCode: Code[20]; pLotNo: Code[50]; pQty: Decimal; pAmount: Decimal; pBatchNumber: Code[20]; pFacilityID: Code[15]; pLineID: Integer; pEventID: Integer; pFirstLine: Boolean; pPost: Boolean; pVicinitySetup: Record "Vicinity Setup"; pSourceCodeSetup: Record "Source Code Setup"; pLotExpirationDate: Date; psGlobalDimensionCode1: Text; psGlobalDimensionCode2: Text; pcodGenBusPostingGroup: Code[20])
    begin
        PostingDate := pPostingDate;
        DocumentNo := pDocumentNo;
        ItemNo := pItemNo;
        LocationCode := pLocationCode;
        BinCode := pBinCode;
        UoMCode := pUoMCode;
        LotNo := pLotNo;
        Qty := pQty;
        Amount := pAmount;
        BatchNumber := pBatchNumber;
        FacilityID := pFacilityID;
        LineID := pLineID;
        EventID := pEventID;
        FirstLine := pFirstLine;
        Post := pPost;
        VicinitySetup := pVicinitySetup;
        SourceCodeSetup := pSourceCodeSetup;
        LotExpirationDate := pLotExpirationDate;
        sGlobalDimensionCode1 := psGlobalDimensionCode1;
        sGlobalDimensionCode2 := psGlobalDimensionCode2;
        codGenBusPostingGroup := pcodGenBusPostingGroup;
    end;

    local procedure AddProdJournalLine(
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        ProdOrderNo: Code[20];
        EntryType: Enum "Item Journal Entry Type";
        ItemNo: Code[20];
        Qty: Decimal;
        LocationCode: Code[10];
        PostingDate: Date;
        DocumentNo: Code[20])
    var
        IJL: Record "Item Journal Line";
        NextLineNo: Integer;
    begin
        if ItemNo = '' then
            Error('Item No. is required.');
        if Qty = 0 then
            Error('Quantity must be non-zero.');

        NextLineNo := GetNextLineNo(JnlTemplateName, JnlBatchName);

        IJL.Init();
        IJL.Validate("Journal Template Name", JnlTemplateName);
        IJL.Validate("Journal Batch Name", JnlBatchName);
        IJL.Validate("Line No.", NextLineNo);

        // Core posting fields
        IJL.Validate("Posting Date", PostingDate);
        IJL.Validate("Document No.", DocumentNo);

        // Set Production context (IMPORTANT if you want this tied to a Prod. Order)
        if ProdOrderNo <> '' then begin
            IJL.Validate("Order Type", IJL."Order Type"::Production);
            IJL.Validate("Order No.", ProdOrderNo);
            IJL.Validate("Order Line No.", 10000);
        end;

        // Line specifics
        IJL.Validate("Entry Type", EntryType);
        IJL.Validate("Item No.", ItemNo);
        IJL.Validate("Source No.", ItemNo); // Using Item No. as Source No. for tracking

        if LocationCode <> '' then
            IJL.Validate("Location Code", LocationCode);

        // For Consumption + Output journals, Qty is typically entered as a positive number.
        // BC will handle sign based on Entry Type when posting.
        IJL.Validate(Quantity, Qty);

        IJL.Insert(true);
    end;

    local procedure GetNextLineNo(JnlTemplateName: Code[10]; JnlBatchName: Code[10]) NextLineNo: Integer
    var
        IJL: Record "Item Journal Line";
    begin
        IJL.SetRange("Journal Template Name", JnlTemplateName);
        IJL.SetRange("Journal Batch Name", JnlBatchName);

        if IJL.FindLast() then
            exit(IJL."Line No." + 10000);

        exit(10000);
    end;


    local procedure InsertItemJournal()
    var
        applyToEventNo: Integer;
    begin
        VicinitySetup.TestField("Vicinity Enabled");
        VicinitySetup.TestField("Item Journal Batch");
        VicinitySetup.TestField("Gen. Bus. Posting Group");
        SourceCodeSetup.TestField("Item Journal");

        // V4-2101 : if item is blank, then we're skipping write to item journal but we may be posting.
        if (ItemNo = '') then begin
            if Post then begin
                ItemJnlLine.Reset();
                ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
                ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
                ItemJnlPostBatch.Run(ItemJnlLine);
            end;
            exit;
        end;

        LineNo := 0;
        if FirstLine then begin
            ReservationEntry.Reset;
            ReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
            ReservationEntry.SetRange("Source ID", ItemJnlTemplate);
            ReservationEntry.SetRange("Source Batch Name", VicinitySetup."Item Journal Batch");
            if ReservationEntry.IsEmpty = false then
                ReservationEntry.DeleteAll(true);

            ItemJnlLine.Reset();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
            ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
            if ItemJnlLine.IsEmpty = false then begin
                ItemJnlLine.DeleteAll(true);
            end
        end
        else begin
            ItemJnlLine.Reset();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
            ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
            if ItemJnlLine.FindLast() then
                LineNo := ItemJnlLine."Line No.";
        end;

        LineNo += 10000;

        if PostingDate = 0D then
            PostingDate := WorkDate();

        applyToEventNo := 0;
        if DocumentNo <> '' then begin
            Evaluate(applyToEventNo, DocumentNo);
            DocumentNo := '';
        end;

        if DocumentNo = '' then begin
            ItemJournalBatch.Get(ItemJnlTemplate, VicinitySetup."Item Journal Batch");
            ItemJournalBatch.TestField("No. Series");
            DocumentNo := NoSeriesMgt.PeekNextNo(ItemJournalBatch."No. Series", TODAY);
        end;

        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := ItemJnlTemplate;
        ItemJnlLine."Journal Batch Name" := VicinitySetup."Item Journal Batch";
        ItemJnlLine."Line No." := LineNo;
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine.Validate("Expiration Date", LotExpirationDate);
        ItemJnlLine."Source No." := VicinityLabel;
        ItemJnlLine."Source Code" := SourceCodeSetup."Item Journal";
        ItemJnlLine.Validate("Document No.", DocumentNo);

        if (applyToEventNo <> 0) then
            ItemJnlLine."Applies-to Entry" := applyToEventNo;

        ItemJnlLine.VALIDATE("Item No.", ItemNo);

        if (codGenBusPostingGroup <> '') then
            ItemJnlLine.Validate("Gen. Bus. Posting Group", codGenBusPostingGroup)
        else
            // V4-2337 : Use the Gen. Bus. Posting Group from Vicinity Setup.
            ItemJnlLine."Gen. Bus. Posting Group" := VicinitySetup."Gen. Bus. Posting Group";

        if LocationCode <> '' then
            ItemJnlLine.VALIDATE("Location Code", LocationCode);

        if BinCode <> '' then
            ItemJnlLine.VALIDATE("Bin Code", BinCode);

        if UoMCode <> '' then
            ItemJnlLine.VALIDATE("Unit of Measure Code", UoMCode);

        if LotNo <> '' then
            ItemJnlLine."Lot No." := LotNo;

        if Qty > 0 then begin
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
            ItemJnlLine.VALIDATE(Quantity, Qty);
            ItemJnlLine.VALIDATE(Amount, Amount);
        end else begin
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
            ItemJnlLine.VALIDATE(Quantity, Abs(Qty));
            ItemJnlLine.VALIDATE(Quantity);


        end;

        // V4-2337
        if (sGlobalDimensionCode1 <> '') then begin
            ItemJnlLine.Validate("Shortcut Dimension 1 Code", sGlobalDimensionCode1);
        end;
        if (sGlobalDimensionCode2 <> '') then begin
            ItemJnlLine.Validate("Shortcut Dimension 2 Code", sGlobalDimensionCode2);
        end;

        // BC 20.0.0.0 - MUST SET LOT NO TO A BLANK -- AFTER THE VALIDATION.
        ItemJnlLine."Lot No." := '';

        ItemJnlLine."Vicinity Batch No." := BatchNumber;
        ItemJnlLine."Vicinity Facility ID" := FacilityID;
        ItemJnlLine."Vicinity Line ID No." := LineID;
        ItemJnlLine."Vicinity Event ID No." := EventID;

        ItemJnlLine."Called From Vicinity" := TRUE;
        ItemJnlLine.INSERT;

        // Lot Tracking
        //        if ItemJnlLine."Lot No." <> '' then begin
        if LotNo <> '' then begin
            Item.GET(ItemJnlLine."Item No.");
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.GET(Item."Item Tracking Code");
                if ItemTrackingCode."Lot Specific Tracking" then begin
                    //set reservation entry which does the lot entries
                    ReservationEntry.Reset();
                    if ReservationEntry.FindLast() then
                        EntryNo := ReservationEntry."Entry No." + 1
                    else
                        EntryNo := 1;

                    ReservationEntry.Init();
                    ReservationEntry."Entry No." := EntryNo;

                    ReservationEntry."Item No." := ItemJnlLine."Item No.";
                    ReservationEntry."Location Code" := ItemJnlLine."Location Code";
                    ReservationEntry."Lot No." := LotNo; // ItemJnlLine."Lot No.";
                    ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
                    ReservationEntry."Creation Date" := ItemJnlLine."Posting Date";
                    ReservationEntry."Source Type" := 83;
                    ReservationEntry."Source ID" := ItemJnlLine."Journal Template Name";
                    ReservationEntry."Source Batch Name" := ItemJnlLine."Journal Batch Name";
                    ReservationEntry."Source Ref. No." := ItemJnlLine."Line No.";

                    if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt." then begin
                        ReservationEntry.Positive := TRUE;
                        ReservationEntry.Quantity := ItemJnlLine.Quantity;
                        ReservationEntry."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
                        ReservationEntry."Source Subtype" := 2;
                        ReservationEntry."Expected Receipt Date" := ItemJnlLine."Posting Date";

                        // V4-2211 : Expiration date not transferring to ILE.
                        ReservationEntry."Expiration Date" := LotExpirationDate; // ItemJnlLine."Expiration Date";
                    end else begin
                        ReservationEntry.Quantity := -ItemJnlLine.Quantity;
                        ReservationEntry."Quantity (Base)" := -ItemJnlLine."Quantity (Base)";
                        ReservationEntry."Source Subtype" := 3;
                        ReservationEntry."Shipment Date" := ItemJnlLine."Posting Date";
                    end;

                    ReservationEntry."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
                    ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry.Insert();
                end;
            end;
        end;

        if Post then begin
            ItemJnlLine.Reset();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
            ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
            ItemJnlPostBatch.Run(ItemJnlLine);
        end;
    end;

    var
        PostingDate: Date;
        LotExpirationDate: Date;
        DocumentNo: Text;
        ItemNo: Code[20];
        LocationCode: Code[20];
        BinCode: Code[20];
        UoMCode: Code[20];
        LotNo: Code[50];
        Qty: Decimal;
        Amount: Decimal;
        BatchNumber: Code[20];
        FacilityID: Code[15];
        LineID: Integer;
        EventID: Integer;
        Post: Boolean;
        FirstLine: Boolean;
        VicinitySetup: Record "Vicinity Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlLine: Record "Item Journal Line";
        Item: Record "Item";
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJnlTemplate: Label 'ITEM';
        VicinityLabel: Label 'VICINITY';
        LineNo: Integer;
        EntryNo: Integer;
        NoSeriesMgt: Codeunit "No. Series";
        sGlobalDimensionCode1: Text[20];
        sGlobalDimensionCode2: Text[20];
        codGenBusPostingGroup: Code[20];
}