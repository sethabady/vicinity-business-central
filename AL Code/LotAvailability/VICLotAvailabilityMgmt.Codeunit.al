codeunit 50450 "VIC Lot Availability Mgt."
{
    /// <summary>
    /// Returns inventory availability information for an item/lot/location/bin.
    ///
    /// All quantities are returned in the item's base unit of measure.
    ///
    /// BinQtyOnHand:
    ///   For a bin-mandatory location, physical quantity in the specified bin.
    ///   For a non-bin location, equals LotQtyOnHand.
    ///
    /// LotQtyOnHand:
    ///   Physical remaining inventory for the lot at the location.
    ///
    /// LotQtyReserved:
    ///   Quantity of the lot reserved at the location.
    ///
    /// LotQtyAvailable:
    ///   LotQtyOnHand - LotQtyReserved.
    /// </summary>
    procedure GetLotAvailability(
        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10];
        BinCode: Code[20];
        var IsLotTracked: Boolean;
        var BinQtyOnHand: Decimal;
        var QuantityOnHand: Decimal;
        var QuantityReserved: Decimal;
        var QuantityAvailable: Decimal)
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        Location: Record Location;
    begin
        Clear(IsLotTracked);
        Clear(BinQtyOnHand);
        Clear(QuantityOnHand);
        Clear(QuantityReserved);
        Clear(QuantityAvailable);

        //
        // Validate common parameters.
        //
        if ItemNo = '' then
            Error('Item No. must be specified.');

        if not Item.Get(ItemNo) then
            Error(
                'Item %1 does not exist.',
                ItemNo);

        if LocationCode = '' then
            Error('Location Code must be specified.');

        if not Location.Get(LocationCode) then
            Error(
                'Location %1 does not exist.',
                LocationCode);

        //
        // Determine whether this item uses lot tracking.
        //
        IsLotTracked := false;

        if Item."Item Tracking Code" <> '' then
            if ItemTrackingCode.Get(Item."Item Tracking Code") then
                IsLotTracked := ItemTrackingCode."Lot Specific Tracking";

        if IsLotTracked then begin
            
            //
            // Lot No. is required only for lot-tracked items.
            //
            if LotNo = '' then
                Error(
                    'Lot No. must be specified for lot-tracked item %1.',
                    ItemNo);

            if not LotExists(ItemNo, LocationCode, LotNo) then
                Error(
                    'Lot %1 does not exist for item %2 at location %3.',
                    LotNo,
                    ItemNo,
                    LocationCode);

            //
            // Quantity for this specific lot/location.
            //
            QuantityOnHand :=
                GetLotQtyOnHand(
                    ItemNo,
                    LotNo,
                    LocationCode);

            //
            // Reservations for this specific lot/location.
            //
            QuantityReserved :=
                GetLotQtyReserved(
                    ItemNo,
                    LotNo,
                    LocationCode);

        end else begin

            //
            // Item isn't lot tracked.
            // Return total inventory at the location.
            //
            QuantityOnHand :=
                GetItemQtyOnHand(
                    ItemNo,
                    LocationCode);

            //
            // Return reservations for the item/location.
            //
            QuantityReserved :=
                GetItemQtyReserved(
                    ItemNo,
                    LocationCode);
        end;

        //
        // Available inventory.
        //
        QuantityAvailable :=
            QuantityOnHand - QuantityReserved;

        if QuantityAvailable < 0 then
            QuantityAvailable := 0;

        //
        // Bin quantity is optional.
        //
        // Only calculate it when a Bin Code was supplied.
        //
        if BinCode <> '' then begin
            if not Location."Bin Mandatory" then
                Error(
                    'Location %1 does not use mandatory bins.',
                    LocationCode);

            if IsLotTracked then
                BinQtyOnHand :=
                    GetBinQtyOnHand(
                        ItemNo,
                        LotNo,
                        LocationCode,
                        BinCode)
            else
                BinQtyOnHand :=
                    GetItemBinQtyOnHand(
                        ItemNo,
                        LocationCode,
                        BinCode);
        end;
    end;

    local procedure GetLotQtyOnHand(
        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10]): Decimal
    var
        LotQtyQuery: Query "VIC Lot Qty. On Hand";
        Quantity: Decimal;
    begin
        LotQtyQuery.SetRange(ItemNoFilter, ItemNo);
        LotQtyQuery.SetRange(LocationCodeFilter, LocationCode);
        LotQtyQuery.SetRange(LotNoFilter, LotNo);

        LotQtyQuery.Open();

        if LotQtyQuery.Read() then
            Quantity := LotQtyQuery.RemainingQuantity;

        LotQtyQuery.Close();

        exit(Quantity);
    end;

    local procedure GetBinQtyOnHand(
        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10];
        BinCode: Code[20]): Decimal
    var
        BinQtyQuery: Query "VIC Bin Qty. On Hand";
        Quantity: Decimal;
    begin
        BinQtyQuery.SetRange(ItemNoFilter, ItemNo);
        BinQtyQuery.SetRange(LocationCodeFilter, LocationCode);
        BinQtyQuery.SetRange(BinCodeFilter, BinCode);
        BinQtyQuery.SetRange(LotNoFilter, LotNo);

        BinQtyQuery.Open();

        if BinQtyQuery.Read() then
            Quantity := BinQtyQuery.QuantityBase;

        BinQtyQuery.Close();

        exit(Quantity);
    end;

    local procedure GetItemBinQtyOnHand(
        ItemNo: Code[20];
        LocationCode: Code[10];
        BinCode: Code[20]): Decimal
    var
        BinQtyQuery: Query "VIC Bin Qty. On Hand";
        Quantity: Decimal;
    begin
        BinQtyQuery.SetRange(
            ItemNoFilter,
            ItemNo);

        BinQtyQuery.SetRange(
            LocationCodeFilter,
            LocationCode);

        BinQtyQuery.SetRange(
            BinCodeFilter,
            BinCode);

        //
        // Deliberately do NOT set LotNoFilter.
        //
        BinQtyQuery.Open();

        if BinQtyQuery.Read() then
            Quantity := BinQtyQuery.QuantityBase;

        BinQtyQuery.Close();

        exit(Quantity);
end;    

    local procedure GetLotQtyReserved(
        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10]): Decimal
    var
        ReservedQtyQuery: Query "VIC Lot Qty. Reserved";
        Quantity: Decimal;
    begin
        ReservedQtyQuery.SetRange(ItemNoFilter, ItemNo);
        ReservedQtyQuery.SetRange(LocationCodeFilter, LocationCode);
        ReservedQtyQuery.SetRange(LotNoFilter, LotNo);

        ReservedQtyQuery.Open();

        if ReservedQtyQuery.Read() then
            //
            // Demand-side Reservation Entries are negative.
            // Return reserved quantity as a positive number.
            //
            Quantity := -ReservedQtyQuery.QuantityBase;

        ReservedQtyQuery.Close();

        if Quantity < 0 then
            Quantity := 0;

        exit(Quantity);
    end;

    local procedure ValidateParameters(
        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10])
    var
        Item: Record Item;
        Location: Record Location;
    begin
        if ItemNo = '' then
            Error('Item No. must be specified.');

        if LotNo = '' then
            Error('Lot No. must be specified.');

        if LocationCode = '' then
            Error('Location Code must be specified.');

        if not Item.Get(ItemNo) then
            Error(
                'Item %1 does not exist.',
                ItemNo);

        if not Location.Get(LocationCode) then
            Error(
                'Location %1 does not exist.',
                LocationCode);

        if not LotExists(ItemNo, LocationCode, LotNo) then
            Error(
                'Lot %1 does not exist for item %2 at location %3.',
                LotNo,
                ItemNo,
                LocationCode);
    end;

    local procedure LotExists(
        ItemNo: Code[20];
        LocationCode: Code[10];
        LotNo: Code[50]
    ): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);

        exit(not ItemLedgerEntry.IsEmpty());
    end;   

    local procedure GetItemQtyOnHand(
        ItemNo: Code[20];
        LocationCode: Code[10]): Decimal
    var
        ItemQtyQuery: Query "VIC Item Qty. On Hand";
        Quantity: Decimal;
    begin
        ItemQtyQuery.SetRange(
            ItemNoFilter,
            ItemNo);

        ItemQtyQuery.SetRange(
            LocationCodeFilter,
            LocationCode);

        ItemQtyQuery.Open();

        if ItemQtyQuery.Read() then
            Quantity := ItemQtyQuery.RemainingQuantity;

        ItemQtyQuery.Close();

        exit(Quantity);
    end;

    local procedure GetItemQtyReserved(
        ItemNo: Code[20];
        LocationCode: Code[10]): Decimal
    var
        ReservedQtyQuery: Query "VIC Item Qty. Reserved";
        Quantity: Decimal;
    begin
        ReservedQtyQuery.SetRange(
            ItemNoFilter,
            ItemNo);

        ReservedQtyQuery.SetRange(
            LocationCodeFilter,
            LocationCode);

        ReservedQtyQuery.Open();

        if ReservedQtyQuery.Read() then
            Quantity := -ReservedQtyQuery.QuantityBase;

        ReservedQtyQuery.Close();

        if Quantity < 0 then
            Quantity := 0;

        exit(Quantity);
    end;
}
