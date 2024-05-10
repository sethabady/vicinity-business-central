codeunit 50148 "VICWarehouseService"
{
    [ServiceEnabled]
    procedure GetLotNumbersByBin(itemNo: Text) Output: Text
    var
        LotNosByBinCode: Query "Lot Numbers by Bin";
        LotBinBuffer: Record "Lot Bin Buffer" temporary;
        JsonLotNumbersByBin: JsonArray;
        JsonLotNumberByBinQuantity: JsonObject;
    begin
        LotNosByBinCode.SetRange(Item_No, itemNo);
        LotNosByBinCode.SetFilter(Lot_No, '<>%1', '');
        LotNosByBinCode.Open();
        while LotNosByBinCode.Read() do begin
            LotBinBuffer.Init();
            LotBinBuffer."Item No." := LotNosByBinCode.Item_No;
            LotBinBuffer."Variant Code" := LotNosByBinCode.Variant_Code;
            LotBinBuffer."Zone Code" := LotNosByBinCode.Zone_Code;
            LotBinBuffer."Bin Code" := LotNosByBinCode.Bin_Code;
            LotBinBuffer."Location Code" := LotNosByBinCode.Location_Code;
            LotBinBuffer."Lot No." := LotNosByBinCode.Lot_No;
            if LotBinBuffer.Find() then begin
                LotBinBuffer."Qty. (Base)" += LotNosByBinCode.Sum_Qty_Base;
                LotBinBuffer.Modify();
            end else begin
                LotBinBuffer."Qty. (Base)" := LotNosByBinCode.Sum_Qty_Base;
                LotBinBuffer.Insert();
            end;
        end;
        if LotBinBuffer.Find('-') then begin
            // Initialize the json object.
            JsonLotNumberByBinQuantity.Add('item_no', '');
            JsonLotNumberByBinQuantity.Add('bin_code', '');
            JsonLotNumberByBinQuantity.Add('location_code', '');
            JsonLotNumberByBinQuantity.Add('quantity', '');
            repeat
                // Populate the json object and add to array.
                JsonLotNumberByBinQuantity.Replace('item_no', LotBinBuffer."Item No.");
                JsonLotNumberByBinQuantity.Replace('bin_code', LotBinBuffer."Bin Code");
                JsonLotNumberByBinQuantity.Replace('location_code', LotBinBuffer."Location Code");
                JsonLotNumberByBinQuantity.Replace('quantity', LotBinBuffer."Qty. (Base)");
                JsonLotNumbersByBin.Add((JsonLotNumberByBinQuantity));
            until LotBinBuffer.Next() = 0;
        end;
        exit(Format(JsonLotNumbersByBin));
    end;
}
