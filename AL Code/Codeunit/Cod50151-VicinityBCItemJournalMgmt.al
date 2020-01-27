codeunit 50151 "Vicinity BC Item Journal Mgmt"
{
    trigger OnRun()
    begin
        InsertItemJournal();
    end;

    procedure SetItemJournalParameters(pPostingDate: Date; pDocumentNo: Text; pItemNo: Code[20]; pLocationCode: Code[20]; pBinCode: Code[20]; pUoMCode: Code[20]; pLotNo: Code[20]; pQty: Decimal; pAmount: Decimal; pBatchNumber: Code[20]; pFacilityID: Code[15]; pLineID: Integer; pEventID: Integer; pFirstLine: Boolean; pPost: Boolean; pVicinitySetup: Record "Vicinity Setup"; pSourceCodeSetup: Record "Source Code Setup")
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
    end;

    local procedure InsertItemJournal()
    begin
        VicinitySetup.TestField("Vicinity Enabled");
        VicinitySetup.TestField("Item Journal Batch");
        VicinitySetup.TestField("Gen. Bus. Posting Group");

        SourceCodeSetup.TestField("Item Journal");

        LineNo := 0;
        if FirstLine then begin
            ItemJnlLine.Reset();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
            ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
            if ItemJnlLine.IsEmpty = false then
                ItemJnlLine.DeleteAll();
        end else begin
            ItemJnlLine.Reset();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate);
            ItemJnlLine.SetRange("Journal Batch Name", VicinitySetup."Item Journal Batch");
            if ItemJnlLine.FindLast() then
                LineNo := ItemJnlLine."Line No.";
        end;

        LineNo += 10000;

        if PostingDate = 0D then
            PostingDate := WorkDate();

        if DocumentNo = '' then begin
            ItemJournalBatch.Get(ItemJnlTemplate, VicinitySetup."Item Journal Batch");
            ItemJournalBatch.TestField("No. Series");
            DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", TODAY, FALSE);
        end;

        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := ItemJnlTemplate;
        ItemJnlLine."Journal Batch Name" := VicinitySetup."Item Journal Batch";
        ItemJnlLine."Line No." := LineNo;
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine."Source No." := VicinityLabel;
        ItemJnlLine."Source Code" := SourceCodeSetup."Item Journal";
        ItemJnlLine."Document No." := DocumentNo;

        ItemJnlLine.VALIDATE("Item No.", ItemNo);
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

        ItemJnlLine."Vicinity Batch No." := BatchNumber;
        ItemJnlLine."Vicinity Facility ID" := FacilityID;
        ItemJnlLine."Vicinity Line ID No." := LineID;
        ItemJnlLine."Vicinity Event ID No." := EventID;

        ItemJnlLine."Called From Vicinity" := TRUE;
        ItemJnlLine.INSERT;

        // Lot Tracking
        if ItemJnlLine."Lot No." <> '' then begin
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
                    ReservationEntry."Lot No." := ItemJnlLine."Lot No.";
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
        DocumentNo: Text;
        ItemNo: Code[20];
        LocationCode: Code[20];
        BinCode: Code[20];
        UoMCode: Code[20];
        LotNo: Code[20];
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
        NoSeriesMgt: Codeunit NoSeriesManagement;
}