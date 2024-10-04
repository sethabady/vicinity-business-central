codeunit 50152 "VICStandardCostService"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure AddToStandardCostWorksheet(worksheetName: Text; initialize: Boolean; standardCostWorksheets: JsonArray) Output: Text
    var
        StandardCostWorksheet: Record "Standard Cost Worksheet";
        WorksheetDetail: JsonToken;
        Item: Record Item;
        LineNo: Integer;
        ComponentId: Text[32];
        VICJsonUtilities: Codeunit VICJSONUtilities;
        ErrInfo: ErrorInfo;
        ErrorMessage: Text;
    begin
        StandardCostWorksheet.Reset();
        StandardCostWorksheet.SetCurrentKey("Standard Cost Worksheet Name");
        StandardCostWorksheet.SetRange("Standard Cost Worksheet Name", worksheetName);
        if initialize then
            StandardCostWorksheet.DeleteAll();
        foreach WorksheetDetail in standardCostWorksheets do begin
            ComponentId := VICJsonUtilities.GetTextFromJson(WorksheetDetail, 'ComponentId');
            if Item.Get(ComponentId) then begin
                StandardCostWorksheet.Init();
                StandardCostWorksheet."Standard Cost Worksheet Name" := worksheetName;
                StandardCostWorksheet."No." := ComponentId;
                StandardCostWorksheet."New Standard Cost" := VICJsonUtilities.GetDecimalFromJson(WorksheetDetail, 'NewStandardCost');
                StandardCostWorksheet."Standard Cost" := Item."Standard Cost";
                if not StandardCostWorksheet.Insert() then begin
                    Output := 'Error inserting ' + ComponentId;
                    Exit;
                end;
            end
        end;
    end;
}