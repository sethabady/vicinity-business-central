query 50160 GetBCBinContents
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'GetBCBinContents';
    EntitySetName = 'GetBCBinContents';
    Caption = 'GetBCBinContents';

    elements
    {
        dataitem(Bin_Content; "Bin Content")
        {
            column(Item_No; "Item No.")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Bin_Code; "Bin Code")
            {

            }
            column(Default; Default)
            {

            }
        }
    }
}