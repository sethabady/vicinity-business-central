query 50178 VICGeneralPostingGroups
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICGeneralPostingGroups';
    EntitySetName = 'VICGeneralPostingGroups';
    Caption = 'Vicinity General Posting Groups';

    elements
    {
        dataitem(GeneralBusinessPostingGroup; "Gen. Business Posting Group")
        {
            column(Code;Code)
            { }
            column(Description;Description)
            {}
        }
    }
}