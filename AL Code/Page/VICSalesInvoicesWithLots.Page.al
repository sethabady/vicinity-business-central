// page 50171 "VICSalesInvoicesWithLots"
// {
//     PageType = API;
//     APIPublisher = 'Vicinity';
//     APIGroup = 'App1';
//     APIVersion = 'v1.0';
//     EntityName = 'VICSalesInvoicesWithLots';
//     EntitySetName = 'VICSalesInvoicesWithLots';
//     DelayedInsert = true;
//     SourceTable = "Sales Invoice Line";
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     Caption = 'Vicinity Sales Invoices With Lots';
//     Permissions = TableData "Item Ledger Entry" = r,
//                   TableData "Value Entry" = r;
//     layout
//     {
//         area(content)
//         {
//             repeater(Control1)
//             {
//                 ShowCaption = false;
//                 field(SellToCustomerNo; Rec."Sell-to Customer No.")
//                 { }
//                 field(DocumentNo; Rec."Document No.")
//                 {
//                     Caption = 'Document No.';
//                     TableRelation = "Sales Invoice Header";
//                 }
//                 field(LineNo; Rec."Line No.")
//                 {
//                     Caption = 'Line No.';
//                 }
//                 field(Type; Rec.Type)
//                 {
//                     Caption = 'Type';
//                 }
//                 field(No; Rec."No.")
//                 {
//                 }
//                 field(LocationCode; Rec."Location Code")
//                 {
//                     Caption = 'Location Code';
//                     TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
//                 }
//                 // field(GOOMBAH; Rec.RowID1)
//                 // { }
//                 // field(GOOMBAH2; GetValueEntryNo(Rec.RowID1))
//                 // { }
//                 // field(GOOMBAH3; GetItemLedgerEntryNo(GetValueEntryNo(Rec.RowID1)))
//                 // { }
//                 field(LotNumber; GetItemLedgerEntryLotNo(GetItemLedgerEntryNo(GetValueEntryNo(Rec.RowID1))))
//                 { }
//                 field(LotQuantity; LotQuantity)
//                 { }
//             }
//         }
//     }

//     var
//         LotQuantity: Decimal;


//     local procedure RowID1(): Text[250]
//     var
//         ItemTrackingMgt: Codeunit "Item Tracking Management";
//     begin
//         exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Invoice Line",
//             0, Rec."Document No.", '', 0, Rec."Line No."));
//     end;

//     local procedure GetValueEntryNo(pSourceRowId: Text[250]) ValueEntryNo: Integer
//     var
//         ValueEntryRelation: Record "Value Entry Relation";
//     begin
//         ValueEntryNo := -1;
//         ValueEntryRelation.Reset();
//         ValueEntryRelation.SetRange("Source RowId", pSourceRowId);
//         if (ValueEntryRelation.Find('-')) then
//             ValueEntryNo := ValueEntryRelation."Value Entry No.";

//         // If ValueEntryRelation.IsEmpty = false then begin
//         //     ValueEntryNo := ValueEntryRelation."Value Entry No.";
//         // end;
//         exit(ValueEntryNo);
//     end;

//     local procedure GetItemLedgerEntryNo(pValueEntryNo: Integer) ItemLedgerEntryNo: Integer
//     var
//         ValueEntry: Record "Value Entry";
//     begin
//         ItemLedgerEntryNo := -1;
//         ValueEntry.Reset();
//         ValueEntry.SetRange("Entry No.", pValueEntryNo);
//         if (ValueEntry.Find('-')) then
//             ItemLedgerEntryNo := ValueEntry."Item Ledger Entry No.";
//         exit(ItemLedgerEntryNo);
//     end;

//     local procedure GetItemLedgerEntryLotNo(pEntryNo: Integer) LotNo: Text[100]
//     var
//         ItemLedgerEntry: Record "Item Ledger Entry";
//     begin
//         LotNo := '';
//         LotQuantity := 0;
//         ItemLedgerEntry.Reset();
//         ItemLedgerEntry.SetRange("Entry No.", pEntryNo);
//         if (ItemLedgerEntry.Find('-')) then begin
//             LotNo := ItemLedgerEntry."Lot No.";
//             LotQuantity := ItemLedgerEntry.Quantity;
//         end;

//         // If ValueEntryRelation.IsEmpty = false then begin
//         //     ValueEntryNo := ValueEntryRelation."Value Entry No.";
//         // end;
//         exit(LotNo);
//     end;


//     // fieldgroups
//     // {
//     //     fieldgroup(Brick; "No.", Description, "Line Amount", "Price description", Quantity, "Unit of Measure Code")
//     //     {
//     //     }
//     // }

//     // trigger OnDelete()
//     // var
//     //     SalesDocLineComments: Record "Sales Comment Line";
//     //     PostedDeferralHeader: Record "Posted Deferral Header";
//     // begin
//     //     SalesDocLineComments.SetRange("Document Type", SalesDocLineComments."Document Type"::"Posted Invoice");
//     //     SalesDocLineComments.SetRange("No.", "Document No.");
//     //     SalesDocLineComments.SetRange("Document Line No.", "Line No.");
//     //     if not SalesDocLineComments.IsEmpty() then
//     //         SalesDocLineComments.DeleteAll();

//     //     PostedDeferralHeader.DeleteHeader(
//     //         "Deferral Document Type"::Sales.AsInteger(), '', '',
//     //         SalesDocLineComments."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
//     // end;

//     // var
//     //     SalesInvoiceHeader: Record "Sales Invoice Header";
//     //     Currency: Record Currency;
//     //     DimMgt: Codeunit DimensionManagement;
//     //     UOMMgt: Codeunit "Unit of Measure Management";
//     //     DeferralUtilities: Codeunit "Deferral Utilities";
//     //     PriceDescriptionTxt: Label 'x%1 (%2%3/%4)', Locked = true;
//     //     PriceDescriptionWithLineDiscountTxt: Label 'x%1 (%2%3/%4) - %5%', Locked = true;

//     // procedure GetCurrencyCode(): Code[10]
//     // begin
//     //     GetHeader;
//     //     exit(SalesInvoiceHeader."Currency Code");
//     // end;

//     // procedure ShowDimensions()
//     // begin
//     //     DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "Document No.", "Line No."));
//     // end;

//     // procedure ShowItemTrackingLines()
//     // var
//     //     ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
//     // begin
//     //     ItemTrackingDocMgt.ShowItemTrackingForInvoiceLine(RowID1);
//     // end;

//     // procedure CalcVATAmountLines(SalesInvHeader: Record "Sales Invoice Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary)
//     // var
//     //     IsHandled: Boolean;
//     // begin
//     //     IsHandled := false;
//     //     OnBeforeCalcVATAmountLines(Rec, SalesInvHeader, TempVATAmountLine, IsHandled);
//     //     if IsHandled then
//     //         exit;

//     //     TempVATAmountLine.DeleteAll();
//     //     SetRange("Document No.", SalesInvHeader."No.");
//     //     if Find('-') then
//     //         repeat
//     //             TempVATAmountLine.Init();
//     //             TempVATAmountLine.CopyFromSalesInvLine(Rec);
//     //             TempVATAmountLine.InsertLine;
//     //         until Next() = 0;
//     // end;

//     // procedure GetLineAmountExclVAT(): Decimal
//     // begin
//     //     GetHeader;
//     //     if not SalesInvoiceHeader."Prices Including VAT" then
//     //         exit("Line Amount");

//     //     exit(Round("Line Amount" / (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
//     // end;

//     // procedure GetLineAmountInclVAT(): Decimal
//     // begin
//     //     GetHeader;
//     //     if SalesInvoiceHeader."Prices Including VAT" then
//     //         exit("Line Amount");

//     //     exit(Round("Line Amount" * (1 + "VAT %" / 100), Currency."Amount Rounding Precision"));
//     // end;

//     // local procedure GetHeader()
//     // begin
//     //     if SalesInvoiceHeader."No." = "Document No." then
//     //         exit;
//     //     if not SalesInvoiceHeader.Get("Document No.") then
//     //         SalesInvoiceHeader.Init();

//     //     if SalesInvoiceHeader."Currency Code" = '' then
//     //         Currency.InitRoundingPrecision
//     //     else
//     //         if not Currency.Get(SalesInvoiceHeader."Currency Code") then
//     //             Currency.InitRoundingPrecision;
//     // end;

//     // local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
//     // var
//     //     "Field": Record "Field";
//     // begin
//     //     Field.Get(DATABASE::"Sales Invoice Line", FieldNumber);
//     //     exit(Field."Field Caption");
//     // end;

//     // procedure GetCaptionClass(FieldNumber: Integer): Text[80]
//     // begin
//     //     GetHeader;
//     //     case FieldNumber of
//     //         FieldNo("No."):
//     //             exit(StrSubstNo('3,%1', GetFieldCaption(FieldNumber)));
//     //         else begin
//     //                 if SalesInvoiceHeader."Prices Including VAT" then
//     //                     exit('2,1,' + GetFieldCaption(FieldNumber));
//     //                 exit('2,0,' + GetFieldCaption(FieldNumber));
//     //             end
//     //     end;
//     // end;

//     // procedure RowID1(): Text[250]
//     // var
//     //     ItemTrackingMgt: Codeunit "Item Tracking Management";
//     // begin
//     //     exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Invoice Line",
//     //         0, "Document No.", '', 0, "Line No."));
//     // end;

//     // procedure GetSalesShptLines(var TempSalesShptLine: Record "Sales Shipment Line" temporary)
//     // var
//     //     SalesShptLine: Record "Sales Shipment Line";
//     //     ItemLedgEntry: Record "Item Ledger Entry";
//     //     ValueEntry: Record "Value Entry";
//     // begin
//     //     TempSalesShptLine.Reset();
//     //     TempSalesShptLine.DeleteAll();

//     //     if Type <> Type::Item then
//     //         exit;

//     //     FilterPstdDocLineValueEntries(ValueEntry);
//     //     if ValueEntry.FindSet() then
//     //         repeat
//     //             ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
//     //             if ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Shipment" then
//     //                 if SalesShptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then begin
//     //                     TempSalesShptLine.Init();
//     //                     TempSalesShptLine := SalesShptLine;
//     //                     if TempSalesShptLine.Insert() then;
//     //                 end;
//     //         until ValueEntry.Next() = 0;
//     // end;

//     // procedure CalcShippedSaleNotReturned(var ShippedQtyNotReturned: Decimal; var RevUnitCostLCY: Decimal; ExactCostReverse: Boolean)
//     // var
//     //     TempItemLedgEntry: Record "Item Ledger Entry" temporary;
//     //     TotalCostLCY: Decimal;
//     //     TotalQtyBase: Decimal;
//     // begin
//     //     ShippedQtyNotReturned := 0;
//     //     if (Type <> Type::Item) or (Quantity <= 0) then begin
//     //         RevUnitCostLCY := "Unit Cost (LCY)";
//     //         exit;
//     //     end;

//     //     RevUnitCostLCY := 0;
//     //     GetItemLedgEntries(TempItemLedgEntry, false);
//     //     if TempItemLedgEntry.FindSet() then
//     //         repeat
//     //             ShippedQtyNotReturned := ShippedQtyNotReturned - TempItemLedgEntry."Shipped Qty. Not Returned";
//     //             if ExactCostReverse then begin
//     //                 TempItemLedgEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
//     //                 TotalCostLCY :=
//     //                   TotalCostLCY + TempItemLedgEntry."Cost Amount (Expected)" + TempItemLedgEntry."Cost Amount (Actual)";
//     //                 TotalQtyBase := TotalQtyBase + TempItemLedgEntry.Quantity;
//     //             end;
//     //         until TempItemLedgEntry.Next() = 0;

//     //     if ExactCostReverse and (ShippedQtyNotReturned <> 0) and (TotalQtyBase <> 0) then
//     //         RevUnitCostLCY := Abs(TotalCostLCY / TotalQtyBase) * "Qty. per Unit of Measure"
//     //     else
//     //         RevUnitCostLCY := "Unit Cost (LCY)";
//     //     ShippedQtyNotReturned := CalcQty(ShippedQtyNotReturned);

//     //     if ShippedQtyNotReturned > Quantity then
//     //         ShippedQtyNotReturned := Quantity;
//     // end;

//     // local procedure CalcQty(QtyBase: Decimal): Decimal
//     // begin
//     //     if "Qty. per Unit of Measure" = 0 then
//     //         exit(QtyBase);
//     //     exit(Round(QtyBase / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision));
//     // end;

//     // procedure GetItemLedgEntries(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SetQuantity: Boolean)
//     // var
//     //     ItemLedgEntry: Record "Item Ledger Entry";
//     //     ValueEntry: Record "Value Entry";
//     //     IsHandled: Boolean;
//     // begin
//     //     IsHandled := false;
//     //     OnBeforeGetItemLedgEntries(Rec, TempItemLedgEntry, SetQuantity, IsHandled);
//     //     if IsHandled then
//     //         exit;

//     //     if SetQuantity then begin
//     //         TempItemLedgEntry.Reset();
//     //         TempItemLedgEntry.DeleteAll();

//     //         if Type <> Type::Item then
//     //             exit;
//     //     end;

//     //     FilterPstdDocLineValueEntries(ValueEntry);
//     //     ValueEntry.SetFilter("Invoiced Quantity", '<>0');
//     //     if ValueEntry.FindSet() then
//     //         repeat
//     //             ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
//     //             TempItemLedgEntry := ItemLedgEntry;
//     //             if SetQuantity then begin
//     //                 TempItemLedgEntry.Quantity := ValueEntry."Invoiced Quantity";
//     //                 if Abs(TempItemLedgEntry."Shipped Qty. Not Returned") > Abs(TempItemLedgEntry.Quantity) then
//     //                     TempItemLedgEntry."Shipped Qty. Not Returned" := TempItemLedgEntry.Quantity;
//     //             end;
//     //             OnGetItemLedgEntriesOnBeforeTempItemLedgEntryInsert(TempItemLedgEntry, ValueEntry, SetQuantity);
//     //             if TempItemLedgEntry.Insert() then;
//     //         until ValueEntry.Next() = 0;
//     // end;

//     // procedure FilterPstdDocLineValueEntries(var ValueEntry: Record "Value Entry")
//     // begin
//     //     ValueEntry.Reset();
//     //     ValueEntry.SetCurrentKey("Document No.");
//     //     ValueEntry.SetRange("Document No.", "Document No.");
//     //     ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
//     //     ValueEntry.SetRange("Document Line No.", "Line No.");
//     // end;

//     // procedure ShowItemShipmentLines()
//     // var
//     //     TempSalesShptLine: Record "Sales Shipment Line" temporary;
//     // begin
//     //     if Type = Type::Item then begin
//     //         GetSalesShptLines(TempSalesShptLine);
//     //         PAGE.RunModal(0, TempSalesShptLine);
//     //     end;
//     // end;

//     // procedure ShowLineComments()
//     // var
//     //     SalesCommentLine: Record "Sales Comment Line";
//     // begin
//     //     SalesCommentLine.ShowComments(SalesCommentLine."Document Type"::"Posted Invoice".AsInteger(), "Document No.", "Line No.");
//     // end;

//     // procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
//     // begin
//     //     DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
//     // end;

//     // procedure InitFromSalesLine(SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
//     // begin
//     //     Init;
//     //     TransferFields(SalesLine);
//     //     if ("No." = '') and HasTypeToFillMandatoryFields() then
//     //         Type := Type::" ";
//     //     "Posting Date" := SalesInvHeader."Posting Date";
//     //     "Document No." := SalesInvHeader."No.";
//     //     Quantity := SalesLine."Qty. to Invoice";
//     //     "Quantity (Base)" := SalesLine."Qty. to Invoice (Base)";

//     //     OnAfterInitFromSalesLine(Rec, SalesInvHeader, SalesLine);
//     // end;

//     // procedure ShowDeferrals()
//     // begin
//     //     DeferralUtilities.OpenLineScheduleView(
//     //         "Deferral Code", "Deferral Document Type"::Sales.AsInteger(), '', '',
//     //         GetDocumentType, "Document No.", "Line No.");
//     // end;

//     // procedure UpdatePriceDescription()
//     // var
//     //     Currency: Record Currency;
//     // begin
//     //     "Price description" := '';
//     //     if Type in [Type::"Charge (Item)", Type::"Fixed Asset", Type::Item, Type::Resource] then begin
//     //         if "Line Discount %" = 0 then
//     //             "Price description" := StrSubstNo(
//     //                 PriceDescriptionTxt, Quantity, Currency.ResolveGLCurrencySymbol(GetCurrencyCode),
//     //                 "Unit Price", "Unit of Measure")
//     //         else
//     //             "Price description" := StrSubstNo(
//     //                 PriceDescriptionWithLineDiscountTxt, Quantity, Currency.ResolveGLCurrencySymbol(GetCurrencyCode),
//     //                 "Unit Price", "Unit of Measure", "Line Discount %")
//     //     end;
//     // end;

//     // procedure FormatType(): Text
//     // var
//     //     SalesLine: Record "Sales Line";
//     // begin
//     //     if Type = Type::" " then
//     //         exit(SalesLine.FormatType);

//     //     exit(Format(Type));
//     // end;

//     // procedure GetDocumentType(): Integer
//     // var
//     //     SalesCommentLine: Record "Sales Comment Line";
//     // begin
//     //     exit(SalesCommentLine."Document Type"::"Posted Invoice".AsInteger())
//     // end;

//     // procedure HasTypeToFillMandatoryFields(): Boolean
//     // begin
//     //     exit(Type <> Type::" ");
//     // end;

//     // procedure IsCancellationSupported(): Boolean
//     // begin
//     //     exit(Type in [Type::" ", Type::Item, Type::"G/L Account", Type::"Charge (Item)"]);
//     // end;

//     // [IntegrationEvent(false, false)]
//     // local procedure OnAfterInitFromSalesLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
//     // begin
//     // end;

//     // [IntegrationEvent(false, false)]
//     // local procedure OnBeforeGetItemLedgEntries(var SalesInvLine: Record "Sales Invoice Line"; var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SetQuantity: Boolean; var IsHandled: Boolean)
//     // begin
//     // end;

//     // [IntegrationEvent(false, false)]
//     // local procedure OnBeforeCalcVATAmountLines(SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var IsHandled: Boolean)
//     // begin
//     // end;

//     // [IntegrationEvent(false, false)]
//     // local procedure OnGetItemLedgEntriesOnBeforeTempItemLedgEntryInsert(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; ValueEntry: Record "Value Entry"; SetQuantity: Boolean)
//     // begin
//     // end;
// }

