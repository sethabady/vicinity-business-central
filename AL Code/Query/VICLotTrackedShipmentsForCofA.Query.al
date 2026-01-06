query 50187 "VICLotTrackedShipmentsForCofA"
{
    QueryType = API;
    APIPublisher = 'Vicinity';
    APIGroup = 'App1';
    APIVersion = 'v1.0';
    EntityName = 'VICLotTrackedShipmentForCofA';
    EntitySetName = 'VICLotTrackedShipmentsForCofA';
    Caption = 'Lot Tracked Shipments with Customer Info for CofA';

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {   
            DataItemTableFilter = "Entry Type" = CONST(Sale),
                                  "Positive" = CONST(false),
                                  "Lot No." = FILTER(<> ''),
                                  "Document Type" = CONST("Sales Shipment");
            column(entryNo_ILE; "Entry No.") {}
            column(entryType_ILE; "Entry Type") {}
            column(documentNo_ILE; "Document No.") {}
            column(lotNumber_ILE; "Lot No.") {}
            column(itemNo_ILE; "Item No.") {}
            column(postingDate_ILE; "Posting Date") {}
            column(quantity_ILE; Quantity) {}
            column(SystemCreatedAt;SystemCreatedAt) {}
            column(SystemModifiedAt;SystemModifiedAt) {}

            // Join to ValueEntry
            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = ItemLedgerEntry."Entry No.";
                column(entryNo_ValueEntry; "Entry No.") {}
                column(documentNo_ValueEntry;"Document No.") {}

                // Join to SalesInvoiceHeader
                dataitem(SalesInvoiceHeader; "Sales Invoice Header")
                {
                    DataItemLink = "No." = ValueEntry."Document No.";
                    column(invoiceNo_SalesInvoiceHeader;"No.") {}
                    column(orderNo_SalesInvoiceHeader;"Order No."){}
                    column(documentDate_SalesInvoiceHeader;"Document Date"){}
                    column(externalDocumentNo_SalesInvoiceHeader;"External Document No.") {}
                    column(sellToCustomerNo_SalesInvoiceHeader;"Sell-to Customer No."){}
                    column(sellToCustomerName_SalesInvoiceHeader;"Sell-to Customer Name") {}
                    column(sellToAddress_SalesInvoiceHeader;"Sell-to Address") {}
                    column(sellToAddress2_SalesInvoiceHeader;"Sell-to Address 2") {}
                    column(sellToCity_SalesInvoiceHeader;"Sell-to City") {}
                    column(sellToCountry_SalesInvoiceHeader;"Sell-to Country/Region Code") {}
                    column(sellToCounty_SalesInvoiceHeader;"Sell-to County") {}
                    column(sellToPostCode_SalesInvoiceHeader;"Sell-to Post Code") {}
                    column(sellToPhoneNo_SalesInvoiceHeader;"Sell-to Phone No.") {}
                    column(sellToE_Mail_SalesInvoiceHeader;"Sell-to E-Mail") {}
                    column(sellToContact_SalesInvoiceHeader;"Sell-to Contact") {}
                    column(sellToContactNo_SalesInvoiceHeader;"Sell-to Contact No.") {}
                    column(billToCustomerNo_SalesInvoiceHeader;"Bill-to Customer No.") {}
                    column(billToName_SalesInvoiceHeader;"Bill-to Name") {}    
                    column(billToName2_SalesInvoiceHeader;"Bill-to Name 2") {}    
                    column(billToAddress_SalesInvoiceHeader;"Bill-to Address") {}    
                    column(billToAddress2_SalesInvoiceHeader;"Bill-to Address 2") {}        
                    column(billToCity_SalesInvoiceHeader;"Bill-to City") {}    
                    column(billToCountry_SalesInvoiceHeader;"Bill-to Country/Region Code") {}   
                    column(billToCounty_SalesInvoiceHeader;"Bill-to County") {}    
                    column(billToPostCode_SalesInvoiceHeader;"Bill-to Post Code") {}
                    column(billToContactNo_SalesInvoiceHeader;"Bill-to Contact No.") {}    
                    column(billToContact_SalesInvoiceHeader;"Bill-to Contact") {}
                    column(shipToName_SalesInvoiceHeader;"Ship-to Name") {}    
                    column(shipToName2_SalesInvoiceHeader;"Ship-to Name 2") {}   
                    column(shipToAddress_SalesInvoiceHeader;"Ship-to Address") {}    
                    column(shipToAddress2_SalesInvoiceHeader;"Ship-to Address 2") {}    
                    column(shipToCity_SalesInvoiceHeader;"Ship-to City") {}    
                    column(shipToCountry_SalesInvoiceHeader;"Ship-to Country/Region Code") {}
                    column(shipToCounty_SalesInvoiceHeader;"Ship-to County") {}    
                    column(shipToPostCode_SalesInvoiceHeader;"Ship-to Post Code") {}
                    column(shipToPhoneNo_SalesInvoiceHeader;"Ship-to Phone No.") {}                 
                    column(shipToContact_SalesInvoiceHeader;"Ship-to Contact") {}    
                    dataitem (SalesInvoiceLine; "Sales Invoice Line")
                    {
                        DataItemLink = "Document No." = SalesInvoiceHeader."No.";
                        column(itemNo_SalesInvoiceLine; "No.") {}
                        column(description_SalesInvoiceLine; Description) {}
                        column(quantity_SalesInvoiceLine; Quantity) {}
                    }
                }
            }
        }
    }
}
