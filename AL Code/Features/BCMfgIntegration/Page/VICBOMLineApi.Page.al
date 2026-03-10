page 50441 VIC_BOMLineAPI
{
    PageType = API;
    Caption = 'vicProductionBOMLineAPI';
    SourceTable = VIC_BOMLine;
    SourceTableTemporary = true;
    APIPublisher = 'VicinitySoftware';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'vicProductionBOMLine';
    EntitySetName = 'vicProductionBOMLines';
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
                field(lineNo; Rec.LineNo)
                {
                }
                field(bomComponentNo; Rec.BOMComponentNo)
                {
                }
                field(quantity; Rec.Quantity)
                {
                }
                field(unitOfMeasure; Rec.UnitOfMeasure)
                {
                }
                field(scrapPercentage; Rec.ScrapPercentage)
                {
                }
                field(type; Rec.Type)
                {
                }
                field(sizingUnitOfMeasure; Rec.SizingUnitOfMeasure)
                {
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { }
            }
        }
    }
}