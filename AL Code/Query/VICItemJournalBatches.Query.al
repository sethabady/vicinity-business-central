query 50179 VICItemJournalBatches
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICItemJournalBatch';
    EntitySetName = 'VICItemJournalBatches';
    Caption = 'Vicinity Item Journal Batches';

    elements
    {
        dataitem(Item_Journal_Batch; "Item Journal Batch")
        {
            column(JournalTemplateName;"Journal Template Name")
            {
            }
            column(Name;Name)
            {
            }
            column(Description;Description)
            {
            }
            column(TemplateType;"Template Type")
            {
            }
        }   
    }
}
