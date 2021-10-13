query 50166 VICCustomers
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICCustomers';
    EntitySetName = 'VICCustomers';
    Caption = 'Vicinity Customers';

    elements
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.")
            { }
            column(Name; Name)
            { }
            column(Name_2; "Name 2")
            { }
            column(Address; Address)
            { }
            column(Address_2; "Address 2")
            { }
            column(City; City)
            { }
            column(County; County)
            { }
            column(Post_Code; "Post Code")
            { }
            column(Country_Region_Code; "Country/Region Code")
            { }
            column(SystemCreatedAt; SystemCreatedAt)
            { }
            column(SystemModifiedAt; SystemModifiedAt)
            { }
            column(SystemId; SystemId)
            { }
        }
    }
}
