page 50442 VIC_RoutingLineAPI
{
    PageType = API;
    Caption = 'vicRoutingLineAPI';
    SourceTable = VIC_RoutingLine;
    SourceTableTemporary = true;
    APIPublisher = 'VicinitySoftware';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'vicProductionRoutingLine';
    EntitySetName = 'vicProductionRoutingLines';
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
                field(operationNo; Rec.OperationNo)
                {
                }
                field(previousOperationNo; Rec.PreviousOperationNo)
                {
                }
                field(nextOperationNo; Rec.NextOperationNo)
                {
                }
                field(workCenterNo; Rec.WorkCenterNo)
                {
                }
                field(lotSize; Rec.LotSize)
                {
                }
                field(setupTime; Rec.SetupTime)
                {
                }
                field(runTime; Rec.RunTime)
                {
                }
                field(postProcessTime; Rec.PostProcessTime)
                {
                }
                field(lastModifiedDateTime; Rec.LastModifiedDateTime)
                {                    
                } 
            }
        }
    }
}