// V4-2152
codeunit 50149 "VICRequisitionService"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure AddToWorksheet(worksheetTemplateName: Text; journalBatchName: Text; initialize: Boolean; vicinityRequisitions: JsonArray) Output: Text
    var
        RequisitionLine: Record "Requisition Line";
        RequisitionDetail: JsonToken;
        Item: Record Item;
        LineNo: Integer;
        ComponentId: Text[32];
        VICJsonUtilities: Codeunit VICJSONUtilities;
        ErrInfo: ErrorInfo;
        ErrorMessage: Text;
    begin
        LineNo := 10000;
        RequisitionLine.Reset();
        RequisitionLine.SetCurrentKey("Worksheet Template Name", "Journal Batch Name", "Line No.");
        RequisitionLine.SetRange("Worksheet Template Name", worksheetTemplateName);
        RequisitionLine.SetRange("Journal Batch Name", journalBatchName);
        if initialize then
            RequisitionLine.DeleteAll();
        if RequisitionLine.FindLast() then
            LineNo := RequisitionLine."Line No." + 10000;
        foreach RequisitionDetail in vicinityRequisitions do begin
            ComponentId := VICJsonUtilities.GetTextFromJson(RequisitionDetail, 'ComponentId');
            if Item.Get(ComponentId) then begin
                RequisitionLine.Init();
                RequisitionLine."Worksheet Template Name" := worksheetTemplateName;
                RequisitionLine."Journal Batch Name" :=  journalBatchName;
                RequisitionLine."Line No." := LineNo;
                LineNo := LineNo + 10000;
                RequisitionLine.Type := "Requisition Line Type"::Item;
                RequisitionLine."No." := ComponentId;
                RequisitionLine.Description := Item.Description;
                RequisitionLine."Location Code" := VICJsonUtilities.GetTextFromJson(RequisitionDetail, 'LocationCode');
                RequisitionLine.Quantity := VICJsonUtilities.GetDecimalFromJson(RequisitionDetail, 'Quantity');
                RequisitionLine."Due Date" := DT2Date(VICJsonUtilities.GetDateFromJson(RequisitionDetail,'DueDate'));
                RequisitionLine."Action Message" := "Action Message Type"::New;
                if not RequisitionLine.Insert() then begin
                    Output := 'Error inserting ' + ComponentId + ' LineNo: ' + Format(LineNo);
                    Exit;
                end;
            end
        end;
    end;
}