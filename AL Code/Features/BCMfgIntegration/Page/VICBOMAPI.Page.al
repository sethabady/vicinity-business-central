page 50440 VIC_BOMAPI
{
    PageType = API;
    Caption = 'vicBOMAPI';
    SourceTable = VIC_BOM;
    SourceTableTemporary = true;
    APIPublisher = 'VicinitySoftware';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'vicProductionBOM';
    EntitySetName = 'vicProductionBOMs';
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                }
                field(bomNo; Rec.BOMNo)
                {
                }
                field(version; Rec.Version)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(unitOfMeasure; Rec.UnitOfMeasure)
                {
                }
                field(productionBOMHeaderSystemId; Rec.ProductionBOMHeaderSystemId)
                {
                }
                field(status; Rec.Status)
                {
                }
                field(routingNo; Rec.RoutingNo)
                {
                }
                field(routingVersion; Rec.RoutingVersion)
                {
                }
                field(routingDescription; Rec.RoutingDescription)
                {
                }
                field(routingStatus; Rec.RoutingStatus)
                {
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                { }
                part(productionBOMLines; VIC_BOMLineAPI)
                {
                    EntityName = 'vicProductionBOMLine';
                    EntitySetName = 'vicProductionBOMLines';
                    SubPageLink = vicProductionBOMId = field(SystemId);
                }
                part(productionRoutingLines; VIC_RoutingLineAPI)
                {
                    EntityName = 'vicProductionRoutingLine';
                    EntitySetName = 'vicProductionRoutingLines';
                    SubPageLink = vicProductionBOMId = field(SystemId);
                }
            }
        }
    }
}
