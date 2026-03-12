page 50443 VIC_BOMRoutingAPI
{
    PageType = API;
    Caption = 'vicBOMRoutingAPI';
    SourceTable = VIC_BOMRouting;
    SourceTableTemporary = true;
    APIPublisher = 'VicinitySoftware';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'vicProductionRouting';
    EntitySetName = 'vicProductionRoutings';
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
                field(routingNo; Rec.RoutingNo)
                {
                }
                field(version; Rec.Version)
                {
                }
                field(description; Rec.Description)
                {
                }
                field(status; Rec.Status)
                {
                }
                part(productionRoutingLines; VIC_BOMRoutingLineAPI)
                {
                    EntityName = 'vicProductionRoutingLine';
                    EntitySetName = 'vicProductionRoutingLines';
                    SubPageLink = vicProductionBOMId = field(SystemId);
                }
            }
        }
    }
}
