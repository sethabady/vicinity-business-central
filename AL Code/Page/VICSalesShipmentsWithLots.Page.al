// page 50170 "VICSalesShipmentsWithLots"
// {
//     PageType = API;
//     APIPublisher = 'Vicinity';
//     APIGroup = 'App1';
//     APIVersion = 'v1.0';
//     EntityName = 'VICSalesShipmentsWithLots';
//     EntitySetName = 'VICSalesShipmentsWithLots';
//     DelayedInsert = true;
//     SourceTable = "Sales Shipment Line";
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     Caption = 'Vicinity Sales Shipments With Lots';

//     layout
//     {
//         area(content)
//         {
//             repeater(Control1)
//             {
//                 ShowCaption = false;
//                 field(DocumentNo; Rec."Document No.")
//                 { }
//                 field(SellToCustomerNo; Rec."Sell-to Customer No.")
//                 { }
//                 field(BillToCustomerNo; Rec."Bill-to Customer No.")
//                 { }
//                 field(Type; Rec.Type)
//                 { }
//                 field(No; Rec."No.")
//                 { }
//                 field(VariantCode; Rec."Variant Code")
//                 { }
//                 field(Description; Rec.Description)
//                 { }
//                 field(Description2; Rec."Description 2")
//                 { }
//                 field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
//                 { }
//                 field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
//                 { }
//                 field(LocationCode; Rec."Location Code")
//                 { }
//                 field(Quantity; Rec.Quantity)
//                 { }
//                 field(UnitOfMeasureCode; Rec."Unit of Measure Code")
//                 { }
//                 field(UnitOfMeasure; Rec."Unit of Measure")
//                 { }
//                 field(ApplToItemEntry; Rec."Appl.-to Item Entry")
//                 { }
//                 field(JobNo; Rec."Job No.")
//                 { }
//                 field(ShipmentDate; Rec."Shipment Date")
//                 { }
//                 field(QuantityInvoiced; Rec."Quantity Invoiced")
//                 { }
//                 field(GOOMBAH; RowID1)
//                 { }
//                 field(GOOMBAH2; GetValueEntryNo(RowID1()))
//                 { }
//             }
//         }
//     }

//     var
//         quantity: Decimal;

//     procedure RowID1(): Text[250]
//     var
//         ItemTrackingMgt: Codeunit "Item Tracking Management";
//     begin
//         exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Shipment Line",
//             0, Rec."Document No.", '', 0, Rec."Line No."));
//     end;

//     local procedure GetValueEntryNo(pSourceRowId: Text[250]) ValueEntryNo: Integer
//     var
//         ValueEntryRelation: Record "Value Entry Relation";
//     begin
//         ValueEntryNo := -1;
//         ValueEntryRelation.Reset();
//         ValueEntryRelation.SetRange("Source RowId", pSourceRowId);
//         If ValueEntryRelation.IsEmpty = false then begin
//             ValueEntryNo := ValueEntryRelation."Value Entry No.";
//         end;
//         exit(ValueEntryNo);
//     end;

//     local procedure GetReservationEntryQuantity() ReservEntryQty: Decimal
//     var
//         ReservationEntry: Record "Reservation Entry";
//     begin
//         ReservEntryQty := 0;

//         // ReservationEntry.Reset();
//         // ReservationEntry.SetRange("Item No.", Rec."Item No.");
//         // ReservationEntry.SetRange("Lot No.", Rec."Lot No.");
//         // ReservationEntry.SetRange(Positive, false);
//         // if ReservationEntry.IsEmpty = false then begin
//         //     ReservationEntry.CalcSums("Quantity (Base)");
//         //     ReservEntryQty := ReservationEntry."Quantity (Base)";
//         // end;

//         exit(ReservEntryQty);
//     end;


// }

