codeunit 50152 "Vicinity MRP Trigger Mgmt"
{
    trigger OnRun()
    begin
    end;

    procedure ClearThenPopulateMRPTrigger(mrpTriggerJson: Text)
    var
        JToken: JsonToken;
        JArray: JsonArray;
        MRPTriggers: JsonToken;
    begin
        JToken.ReadFrom(mrpTriggerJson);
        if not JToken.SelectToken('[' + '''' + 'MRPTriggers' + '''' + ']', MRPTriggers) then begin

        end;
        JArray := MRPTriggers.AsArray();
    end;
}