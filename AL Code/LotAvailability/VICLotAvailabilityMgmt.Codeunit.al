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
        var BinQtyOnHand: Decimal;
        var LotQtyOnHand: Decimal;
        var LotQtyReserved: Decimal;
        var LotQtyAvailable: Decimal)
    var
        Location: Record Location;
    begin
        Clear(BinQtyOnHand);
        Clear(LotQtyOnHand);
        Clear(LotQtyReserved);
        Clear(LotQtyAvailable);

        ValidateParameters(
            ItemNo,
            LotNo,
            LocationCode);

        Location.Get(LocationCode);

        //
        // Physical quantity for the lot at the location.
        //
        LotQtyOnHand :=
            GetLotQtyOnHand(
                ItemNo,
                LotNo,
                LocationCode);

        //
        // Reservations are against the lot/location,
        // not against a specific warehouse bin.
        //
        LotQtyReserved :=
            GetLotQtyReserved(
                ItemNo,
                LotNo,
                LocationCode);

        //
        // Calculate available lot quantity.
        //
        LotQtyAvailable :=
            LotQtyOnHand - LotQtyReserved;

        if LotQtyAvailable < 0 then
            LotQtyAvailable := 0;

        //
        // Bin quantity depends upon whether the location
        // is configured to use bins.
        //
        if Location."Bin Mandatory" then begin
            if BinCode = '' then
                Error(
                    'A bin code is required for location %1 because the location requires bins.',
                    LocationCode);

            BinQtyOnHand :=
                GetBinQtyOnHand(
                    ItemNo,
                    LotNo,
                    LocationCode,
                    BinCode);
        end else
            //
            // There is no meaningful separate bin quantity
            // for a location that does not use bins.
            //
            BinQtyOnHand := LotQtyOnHand;
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
}