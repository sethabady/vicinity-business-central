codeunit 50300 "VICProductionBomService"
{
    // Exposes an unbound OData action.
    // POST .../ODataV4/Microsoft.NAV.UpsertProdBom
    // Body: { "payload": { ... } }

    [ServiceEnabled]
    procedure UpsertProdBom(payload: Text): Text
    var
        Sync: Codeunit vic_ProductionBOMSync;
        Response: Text;
        JsonObjectPayload: JsonObject;
    begin
        JsonObjectPayload.ReadFrom(payload);
        Sync.UpsertFromPayload(JsonObjectPayload).WriteTo(Response);
        exit(Response);
    end;    
}

