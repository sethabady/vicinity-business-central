codeunit 50181 VICPostBatch
{
    TableNo = VICBatch;

    var
        // VICBatch: Record VICBatch;
        // VICBatchEndItem: Record VICBatchEndItem;
        Window: Dialog;

    [IntegrationEvent(false, false)]
    procedure OnPostBatch(FacilityId: Text; BatchNumber: Text; PostThruToBC: Boolean; PostDate: Date)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::VICPostBatch, 'OnPostBatch', '', false, false)]
    local procedure OnPostBatchSubscriber(FacilityId: Text; BatchNumber: Text; PostThruToBC: Boolean; PostDate: Date)
    var
        VICBatchEndItem: Record VICBatchEndItem;
        // Window: Dialog;
        IsHandled: Boolean;
        JsonRequestObject: JsonObject;
        JsonValue: JsonValue;
        JsonBatchTransactions: JsonArray;
        VICWebServiceInterface: Codeunit VICWebApiInterface;
        ResultMessage: Text;
    begin
        OpenProgressDialog(FacilityId, BatchNumber, IsHandled);
        if IsHandled then
            exit;
        VICBatchEndItem.SetRange(FacilityId, FacilityId);
        VICBatchEndItem.SetRange(BatchNumber, BatchNumber);
        VICBatchEndItem.SetFilter(QuantityToComplete, '> 0');
        if not VICBatchEndItem.FindSet() then
            exit;
        JsonValue.SetValue(PostDate);
        JsonRequestObject.Add('TransactionDate', JsonValue);
        JsonRequestObject.Add('UserID', Database.UserId);
        JsonRequestObject.Add('BatchNumber', BatchNumber);
        JsonRequestObject.Add('FacilityId', FacilityId);
        if PostThruToBC then
            JsonRequestObject.Add('GPBatchNumber', 'CBOTTSOP')  // POSTTOBC backwards (for now)
        else
            JsonRequestObject.Add('GPBatchNumber', '');
        repeat
            AddTransactionToJson(VICBatchEndItem, JsonBatchTransactions);
        until VICBatchEndItem.Next() = 0;

        // Add populated transaction array to request object.
        JsonRequestObject.Add('BatchTransactions', JsonBatchTransactions);
        VICWebServiceInterface.OnPostBatchEndItems(JsonRequestObject, IsHandled, ResultMessage);
        Window.Close();
        if IsHandled then begin
            VICBatchEndItem.SetRange(FacilityId, FacilityId);
            VICBatchEndItem.SetRange(BatchNumber, BatchNumber);
            VICBatchEndItem.SetFilter(QuantityToComplete, '> 0');
            if VICBatchEndItem.FindSet() then begin
                repeat
                    VICBatchEndItem.QuantityToComplete := 0;
                    // VICBatchEndItem.LotNumber := '';
                    VICBatchEndItem.Modify();
                until VICBatchEndItem.Next() = 0;
            end;
            Message('The batch end-items were successfully posted.')
        end
        else begin
            Message('PostBatchEndItems error:\\' + ResultMessage);
        end;
    end;

    local procedure AddTransactionToJson(VICBatchEndItem: Record VICBatchEndItem; JsonBatchTransactions: JsonArray)
    var
        JsonBatchTransaction: JsonObject;
        JsonQuantity: JsonObject;
        JsonBatchLot: JsonObject;
        JsonBatchLots: JsonArray;
    begin
        JsonBatchTransaction.Add('ComponentId', VICBatchEndItem.ComponentId);
        JsonBatchTransaction.Add('SiteId', VICBatchEndItem.LocationCode);
        JsonBatchTransaction.Add('BinNumber', VICBatchEndItem.BinCode);
        JsonBatchTransaction.Add('LineIdNumber', VICBatchEndItem.LineIdNumber);

        // Create and add quantity object.
        JsonQuantity.Add('DecimalDigits', 5);
        JsonQuantity.Add('Value', VICBatchEndItem.QuantityToComplete);
        JsonBatchTransaction.Add('Quantity', JsonQuantity);

        // Create and add lot object.
        if VICBatchEndItem.LotNumber <> '' then begin
            JsonBatchLot.Add('LotNumber', VICBatchEndItem.LotNumber);
            JsonBatchLot.Add('ReceiptDate', System.Today());
            JsonBatchLot.Add('MfgDate', System.Today());
            JsonBatchLot.Add('ExpnDate', CalcDate('<+30D>', System.Today()));
            JsonBatchLot.Add('Quantity', JsonQuantity);
            JsonBatchLots.Add(JsonBatchLot);
            JsonBatchTransaction.Add('BatchLots', JsonBatchLots);
        end;

        // Add populated transaction to array of transactions.
        JsonBatchTransactions.Add(JsonBatchTransaction);
    end;

    // trigger OnRun()
    // begin
    //     VICBatch.Copy(Rec);
    //     Code;
    // end;


    // local procedure "Code"()
    // var
    //     IsHandled: Boolean;
    //     ResultMessage: Text;
    //     JsonRequestObject: JsonObject;
    //     JsonValue: JsonValue;
    //     JsonQuantity: JsonObject;
    //     JsonBatchTransactions: JsonArray;
    //     JsonBatchTransaction: JsonObject;
    //     JsonBatchLots: JsonArray;
    //     JsonBatchLot: JsonObject;
    //     VICWebServiceInterface: Codeunit VICWebApiInterface;

    // begin
    //     OpenProgressDialog('', '', IsHandled);
    //     if IsHandled then
    //         exit;
    //     VICBatchEndItem.SetRange(FacilityId, VICBatch.FacilityId);
    //     VICBatchEndItem.SetRange(BatchNumber, VICBatch.BatchNumber);
    //     VICBatchEndItem.SetFilter(QuantityToComplete, '> 0');
    //     if VICBatchEndItem.FindSet() then begin
    //         JsonValue.SetValue(System.Today());
    //         JsonRequestObject.Add('TransactionDate', JsonValue);
    //         JsonRequestObject.Add('UserID', Database.UserId);
    //         JsonRequestObject.Add('BatchNumber', VICBatch.BatchNumber);
    //         JsonRequestObject.Add('FacilityId', VICBatch.FacilityId);
    //         if VICBatch.PostThruToBC then
    //             JsonRequestObject.Add('GPBatchNumber', 'CBOTTSOP')  // POSTTOBC backwards (for now)
    //         else
    //             JsonRequestObject.Add('GPBatchNumber', '');
    //         repeat
    //             JsonBatchTransaction.Add('ComponentId', VICBatchEndItem.ComponentId);
    //             JsonBatchTransaction.Add('SiteId', VICBatchEndItem.LocationCode);
    //             JsonBatchTransaction.Add('BinNumber', VICBatchEndItem.BinCode);
    //             JsonBatchTransaction.Add('LineIdNumber', VICBatchEndItem.LineIdNumber);

    //             // Create and add quantity object.
    //             JsonQuantity.Add('DecimalDigits', 5);
    //             JsonQuantity.Add('Value', VICBatchEndItem.QuantityToComplete);
    //             JsonBatchTransaction.Add('Quantity', JsonQuantity);

    //             // Create and add lot object.
    //             if VICBatchEndItem.LotNumber <> '' then begin
    //                 JsonBatchLot.Add('LotNumber', VICBatchEndItem.LotNumber);
    //                 JsonBatchLot.Add('ReceiptDate', System.Today());
    //                 JsonBatchLot.Add('MfgDate', System.Today());
    //                 JsonBatchLot.Add('ExpnDate', CalcDate('<+30D>', System.Today()));
    //                 JsonBatchLot.Add('Quantity', JsonQuantity);
    //                 JsonBatchLots.Add(JsonBatchLot);
    //                 JsonBatchTransaction.Add('BatchLots', JsonBatchLots);
    //             end;

    //             // Add populated transaction to array of transactions.
    //             JsonBatchTransactions.Add(JsonBatchTransaction);
    //         until VICBatchEndItem.Next() = 0;

    //         // Add populated transaction array to request object.
    //         JsonRequestObject.Add('BatchTransactions', JsonBatchTransactions);
    //         VICWebServiceInterface.OnPostBatchEndItems(JsonRequestObject, IsHandled, ResultMessage);
    //         Window.Close();
    //         if IsHandled then begin
    //             VICBatchEndItem.SetRange(FacilityId, VICBatch.FacilityId);
    //             VICBatchEndItem.SetRange(BatchNumber, VICBatch.BatchNumber);
    //             VICBatchEndItem.SetFilter(QuantityToComplete, '> 0');
    //             if VICBatchEndItem.FindSet() then begin
    //                 repeat
    //                     VICBatchEndItem.QuantityToComplete := 0;
    //                     // VICBatchEndItem.LotNumber := '';
    //                     VICBatchEndItem.Modify();
    //                 until VICBatchEndItem.Next() = 0;
    //             end;
    //             Message('The batch end-items were successfully posted.')
    //         end
    //         else begin
    //             Message('PostBatchEndItems error:\\' + ResultMessage);
    //         end;
    //     end;
    // end;

    local procedure OpenProgressDialog(FacilityId: Text; BatchNumber: Text; var IsHandled: Boolean)
    var
    begin
        IsHandled := false;
        OnBeforeOpenProgressDialog(FacilityId, BatchNumber, IsHandled);
        if IsHandled then
            exit;
        Window.Open('Facility: ' + FacilityId + '\Batch: ' + BatchNumber);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenProgressDialog(FacilityId: Text; BatchNumber: Text; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::VICPostBatch, 'OnBeforeOpenProgressDialog', '', false, false)]
    local procedure OnBeforeOpenProgressDialogSubscriber(FacilityId: Text; BatchNumber: Text; var IsHandled: Boolean)
    var
        VICBatchEndItem: Record VICBatchEndItem;
    begin
        VICBatchEndItem.SetRange(FacilityId, FacilityId);
        VICBatchEndItem.SetRange(BatchNumber, BatchNumber);
        VICBatchEndItem.SetFilter(QuantityToComplete, '> 0');
        if not VICBatchEndItem.FindFirst() then begin
            Dialog.Message('There is nothing to post because all end-item quantities to complete are zero.');
            IsHandled := true;
            exit;
        end;
    end;
}
