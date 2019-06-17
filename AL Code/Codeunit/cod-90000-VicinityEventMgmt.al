codeunit 90000 "Vicinity Event Managment"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure Cod_GenJnlPostLine_OnAfterInitGLEntry(VAR GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Vicinity Batch No." := GenJournalLine."Vicinity Batch No.";
        GLEntry."Vicinity Facility ID" := GenJournalLine."Vicinity Facility ID";
        GLEntry."Vicinity Line ID No." := GenJournalLine."Vicinity Line ID No.";
        GLEntry."Vicinity Event ID No." := GenJournalLine."Vicinity Event ID No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure Cod_ItemJnlPostLine_OnAfterInitItemLedgEntry(VAR NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ItemLedgEntryNo: Integer)
    begin
        NewItemLedgEntry."Vicinity Batch No." := ItemJournalLine."Vicinity Batch No.";
        NewItemLedgEntry."Vicinity Facility ID" := ItemJournalLine."Vicinity Facility ID";
        NewItemLedgEntry."Vicinity Line ID No." := ItemJournalLine."Vicinity Line ID No.";
        NewItemLedgEntry."Vicinity Event ID No." := ItemJournalLine."Vicinity Event ID No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitValueEntry', '', false, false)]
    local procedure Cod_ItemJnlPostLine_OnAfterInitValueEntry(VAR ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ValueEntryNo: Integer)
    begin
        ValueEntry."Vicinity Batch No." := ItemJournalLine."Vicinity Batch No.";
        ValueEntry."Vicinity Facility ID" := ItemJournalLine."Vicinity Facility ID";
        ValueEntry."Vicinity Line ID No." := ItemJournalLine."Vicinity Line ID No.";
        ValueEntry."Vicinity Event ID No." := ItemJournalLine."Vicinity Event ID No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforePostInvtPostBuf', '', false, false)]
    local procedure Cod_InvPosttoGL_OnBeforePostInvtPostBuf(VAR GenJournalLine: Record "Gen. Journal Line"; VAR InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJournalLine."Vicinity Batch No." := ValueEntry."Vicinity Batch No.";
        GenJournalLine."Vicinity Facility ID" := ValueEntry."Vicinity Facility ID";
        GenJournalLine."Vicinity Line ID No." := ValueEntry."Vicinity Line ID No.";
        GenJournalLine."Vicinity Event ID No." := ValueEntry."Vicinity Event ID No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure Cod_GenJnlCheckLine_OnBeforeRunCheck(VAR GenJournalLine: Record "Gen. Journal Line")
    var
        VicinityPopulateGeneralJnl: Codeunit "Vicinity Populate General Jnl";
    begin
        IF GenJournalLine."Called From Vicinity" = TRUE THEN
            VicinityPopulateGeneralJnl.SaveVicinityErrorLogInfo(GenJournalLine, 'Post General Journal'); //Vicinity
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure Cod_ItemJnlCheckLine_OnAfterCheckItemJnlLine(VAR ItemJnlLine: Record "Item Journal Line")
    var
        VicinityPopulateJournal: Codeunit "Vicinity Populate Journal";
    begin
        IF ItemJnlLine."Called From Vicinity" = TRUE THEN
            VicinityPopulateJournal.SaveVicinityErrorLogInfo(ItemJnlLine, 'Post Item Journal'); //Vicinity
    end;
}