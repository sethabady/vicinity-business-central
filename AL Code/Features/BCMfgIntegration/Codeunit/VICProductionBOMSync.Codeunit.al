codeunit 50301 vic_ProductionBOMSync
{
    var
        VICJsonUtilities: Codeunit VICJsonUtilities;

    procedure UpsertFromPayload(payload: JsonObject): JsonObject
    var
        Resp: JsonObject;
        MesBomId: Code[50];
        MesVer: Code[30];
        BomNo: Code[20];
        DescTxt: Text[100];
        StatusTxt: Text;
        DesiredCertified: Boolean;
        Lines: JsonArray;
    begin
        MesBomId := CopyStr(VICJsonUtilities.GetTextFromJson(payload, 'mesBomId'), 1, MaxStrLen(MesBomId));
        MesVer := CopyStr(VICJsonUtilities.GetTextFromJson(payload, 'mesVersion'), 1, MaxStrLen(MesVer));
        DescTxt := CopyStr(VICJsonUtilities.GetTextFromJson(payload, 'description'), 1, MaxStrLen(DescTxt));
        StatusTxt := LowerCase(VICJsonUtilities.GetTextFromJson(payload, 'status')); // 'draft' | 'certified'

        if (MesBomId = '') or (MesVer = '') then
            exit(MakeError('mesBomId and mesVersion are required.', MesBomId, MesVer));

        DesiredCertified := (StatusTxt = 'certified');
        BomNo := ComposeBomNo(MesBomId, MesVer);
        Lines := VICJsonUtilities.GetArray(payload, 'lines');
        Resp := UpsertProductionBom(BomNo, DescTxt, Lines, DesiredCertified);
        exit(Resp);
    end;

    local procedure UpsertProductionBom(BomNo: Code[20]; DescTxt: Text[100]; Lines: JsonArray; DesiredCertified: Boolean) : JsonObject
    var
        H: Record "Production BOM Header";
        L: Record "Production BOM Line";
        Tok: JsonToken;
        Obj: JsonObject;
        DefaultLineNo: Integer;
        ReturnObj: JsonObject;
    begin
        if not H.Get(BomNo) then begin
            H.Init();
            H."No." := BomNo;
            H.Insert(true);
        end;

        EnsureUnderDevelopment(H);
        H.Description := DescTxt;
        H.Modify(true);

        // Replace lines
        L.SetRange("Production BOM No.", BomNo);
        if L.FindSet(true) then
            L.DeleteAll(true);

        DefaultLineNo := 10000;

        foreach Tok in Lines do begin
            if not Tok.IsObject() then
                Error('Each element in lines must be an object.');
            Obj := Tok.AsObject();
            if InsertLine(BomNo, Obj, DefaultLineNo, L) then
                L.Insert()
            else
                Exit(MakeErrorFromLastError('', '', BomNo)); // if InsertLine fails, it will have already set the error context in GetLastErrorText
//                Error('Failed to insert line for item "%1".', GetLastErrorText);
            DefaultLineNo += 10000;
        end;

        if DesiredCertified then
            Certify(H);

        ReturnObj.Add('ok', true);
        ReturnObj.Add('targetBomNo', BomNo);
        ReturnObj.Add('status', ChooseStatusText(DesiredCertified));

        exit(ReturnObj);
    end;

    [TryFunction]
    local procedure InsertLine(BomNo: Code[20]; LineObj: JsonObject; DefaultLineNo: Integer; var L: Record "Production BOM Line")
    var
        //        L: Record "Production BOM Line";
        Item: Record Item;
        UOM: Record "Unit of Measure";
        LineNo: Integer;
        TypeTxt: Text;
        NoTxt: Code[20];
        UomCode: Code[10];
        QtyPer: Decimal;
        ScrapPct: Decimal;
    begin
        LineNo := VICJsonUtilities.GetIntegerFromJson(LineObj, 'lineNo');
        if LineNo = 0 then
            LineNo := DefaultLineNo;

        TypeTxt := LowerCase(VICJsonUtilities.GetTextFromJson(LineObj, 'type')); // expect "item"
        NoTxt := CopyStr(VICJsonUtilities.GetTextFromJson(LineObj, 'no'), 1, MaxStrLen(NoTxt));
        UomCode := CopyStr(VICJsonUtilities.GetTextFromJson(LineObj, 'uomCode'), 1, MaxStrLen(UomCode));
        QtyPer := VICJsonUtilities.GetDecimalFromJson(LineObj, 'quantityPer');
        ScrapPct := VICJsonUtilities.GetDecimalFromJson(LineObj, 'scrapPct');

        if TypeTxt <> 'item' then
            Error('Only type "Item" is supported. Got "%1".', TypeTxt);

        if (NoTxt = '') or (not Item.Get(NoTxt)) then
            Error('Item "%1" does not exist in Business Central.', NoTxt);

        if (UomCode <> '') and (not UOM.Get(UomCode)) then
            Error('Unit of Measure "%1" does not exist in Business Central.', UomCode);

        if QtyPer <= 0 then
            Error('quantityPer must be > 0 for item "%1".', NoTxt);

        L.Init();
        L."Production BOM No." := BomNo;
        L."Line No." := LineNo;
        L.Type := L.Type::Item;

        L.Validate("No.", NoTxt);
        L.Validate("Quantity per", QtyPer);

        if UomCode <> '' then
            L.Validate("Unit of Measure Code", UomCode);

        if ScrapPct <> 0 then
            L.Validate("Scrap %", ScrapPct);

        //        L.Insert(true);
    end;

    local procedure EnsureUnderDevelopment(var H: Record "Production BOM Header")
    begin
        if H.Status <> H.Status::"Under Development" then begin
            H.Status := H.Status::"Under Development";
            H.Modify(true);
        end;
    end;

    local procedure Certify(var H: Record "Production BOM Header")
    begin
        if H.Status <> H.Status::Certified then begin
            H.Status := H.Status::Certified;
            H.Modify(true);
        end;
    end;

    local procedure ComposeBomNo(MesBomId: Code[50]; MesVer: Code[30]): Code[20]
    var
        T: Text;
    begin
        // Example: M12345-V7 (truncate to 20 chars; adjust if you need a different scheme)
        T := StrSubstNo('%1-V%2', MesBomId, MesVer);
        exit(CopyStr(T, 1, 20));
    end;

    local procedure ChooseStatusText(Certified: Boolean): Text
    begin
        if Certified then exit('Certified');
        exit('Under Development');
    end;

    // ---------- Response helpers ----------
    local procedure MakeError(CodeTxt: Text; Msg: Text; MesBomId: Text; MesVer: Text; BomNo: Text; LineNo: Integer; ItemNo: Text; FieldName: Text): JsonObject
    var
        R: JsonObject;
        E: JsonObject;
    begin
        R.Add('ok', false);

        E.Add('code', CodeTxt);
        E.Add('message', Msg);

        if BomNo <> '' then R.Add('targetBomNo', BomNo);
        if MesBomId <> '' then R.Add('mesBomId', MesBomId);
        if MesVer <> '' then R.Add('mesVersion', MesVer);

        if LineNo <> 0 then E.Add('lineNo', LineNo);
        if ItemNo <> '' then E.Add('itemNo', ItemNo);
        if FieldName <> '' then E.Add('field', FieldName);

        R.Add('error', E);
        exit(R);
    end;

    local procedure MakeError(Msg: Text; MesBomId: Text; MesVer: Text): JsonObject
    var
        R: JsonObject;
    begin
        R.Add('ok', false);
        R.Add('message', Msg);
        if MesBomId <> '' then R.Add('mesBomId', MesBomId);
        if MesVer <> '' then R.Add('mesVersion', MesVer);
        exit(R);
    end;

    local procedure MakeErrorFromLastError(MesBomId: Text; MesVer: Text; BomNo: Text): JsonObject
    var
        Txt: Text;
        Tok: JsonToken;
        Obj: JsonObject;
        CodeTxt: Text;
        Msg: Text;
        LineNo: Integer;
        ItemNo: Text;
        FieldName: Text;
    begin
        Txt := GetLastErrorText();

        // If error text is JSON we produced (GetErrorText), parse it and return a structured envelope
        if Tok.ReadFrom(Txt) and Tok.IsObject() then begin
            Obj := Tok.AsObject();
            CodeTxt := VICJsonUtilities.GetTextFromJson(Obj, 'code');
            Msg := VICJsonUtilities.GetTextFromJson(Obj, 'message');
            LineNo := VICJsonUtilities.GetIntegerFromJson(Obj, 'lineNo');
            ItemNo := VICJsonUtilities.GetTextFromJson(Obj, 'itemNo');
            FieldName := VICJsonUtilities.GetTextFromJson(Obj, 'field');

            if CodeTxt <> '' then
                exit(MakeError(CodeTxt, Msg, MesBomId, MesVer, BomNo, LineNo, ItemNo, FieldName));
        end;

        // Fallback for unknown BC errors
        exit(MakeError('BC_VALIDATION', Txt, MesBomId, MesVer, BomNo, 0, '', ''));
    end;

    // // ---------- JSON helpers ----------
    // local procedure GetText(J: JsonObject; Name: Text): Text
    // var
    //     T: JsonToken;
    //     V: JsonValue;
    // begin
    //     if not J.Get(Name, T) then exit('');
    //     if T.IsValue() then begin V := T.AsValue(); exit(V.AsText()); end;
    //     exit('');
    // end;

    // local procedure GetInt(J: JsonObject; Name: Text): Integer
    // var
    //     T: JsonToken;
    //     V: JsonValue;
    //     I: Integer;
    // begin
    //     if not J.Get(Name, T) then exit(0);
    //     if T.IsValue() then begin
    //         V := T.AsValue();
    //         if V.IsNumber() then exit(V.AsInteger());
    //         if V.IsText() then begin
    //             if not Evaluate(I, V.AsText()) then Error('Invalid integer for %1.', Name);
    //             exit(I);
    //         end;
    //     end;
    //     exit(0);
    // end;

    // local procedure GetDec(J: JsonObject; Name: Text): Decimal
    // var
    //     T: JsonToken;
    //     V: JsonValue;
    //     D: Decimal;
    // begin
    //     if not J.Get(Name, T) then exit(0);
    //     if T.IsValue() then begin
    //         V := T.AsValue();
    //         if V.IsNumber() then exit(V.AsDecimal());
    //         if V.IsText() then begin
    //             if not Evaluate(D, V.AsText()) then Error('Invalid decimal for %1.', Name);
    //             exit(D);
    //         end;
    //     end;
    //     exit(0);
    // end;

    // local procedure GetArray(J: JsonObject; Name: Text): JsonArray
    // var
    //     T: JsonToken;
    // begin
    //     if not J.Get(Name, T) then Error('Missing required array "%1".', Name);
    //     if not T.IsArray() then Error('"%1" must be an array.', Name);
    //     exit(T.AsArray());
    // end;
}

