codeunit 50411 VICJSONUtilities
{
    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

    procedure SetDateFromJson(JsonToken: JsonToken; TokenKey: Text; var DateToSet: Date)
    var
        JsonTokenDate: JsonToken;
        DateFromRecord: Text;
        DateParts: List of [Text];
    begin
        JsonTokenDate := GetJsonToken(JsonToken.AsObject(), TokenKey);
        if not JsonTokenDate.AsValue().IsNull() then begin
            DateFromRecord := GetJsonToken(JsonToken.AsObject(), TokenKey).AsValue.AsText();
            DateParts := DateFromRecord.Split('T');
            Evaluate(DateToSet, DateParts.Get(1));
        end;
    end;

    procedure GetDecimalFromJson(Token: JsonToken; TokenKey: Text): Decimal
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsDecimal());
    end;

    procedure GetIntegerFromJson(Token: JsonToken; TokenKey: Text): Integer
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsInteger());
    end;

    procedure GetTextFromJson(Token: JsonToken; TokenKey: Text): Text
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsText());
    end;

    procedure GetBooleanFromJson(Token: JsonToken; TokenKey: Text): Boolean
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsBoolean());
    end;

    procedure GetDateFromJson(Token: JsonToken; TokenKey: Text): DateTime
    var
        DateText: Text;
        // DateParts: List of [Text];
        DateFromJson: DateTime;
        ljtTemp: JsonToken;
    begin
        // V4-2407//V4-2337: added proper support for a null date.
        if (Token.AsObject().Get(TokenKey, ljtTemp)) then begin
            if (ljtTemp.AsValue().IsNull()) then
                exit(0DT);
        end;       

        DateText := GetTextFromJson(Token, TokenKey);

        // Date is expected to be YYYY-MM-DD so we need to remove the time portion.
        // DateParts := DateText.Split('T');
        //        Evaluate(DateFromJson, DateParts.Get(1));

        // 9 means convert from xml format
        Evaluate(DateFromJson, DateText, 9);
        Exit(DateFromJson);
    end;

    procedure CreateJsonObject(): JsonObject
    var
        Json: JsonObject;
    begin
        exit(Json);
    end;

    procedure CreateJsonArray(): JsonArray
    var
        Json: JsonArray;
    begin
        exit(Json);
    end;

    // ---------------------------
    // Safe getters (null tolerant)
    // ---------------------------

    procedure ResolveToObject(Tok: JsonToken; var IdIndex: Dictionary of [Text, Text]): JsonObject
    var
        Obj: JsonObject;
        RefTok: JsonToken;
        RefId: Text;
        RefJson: Text;
    begin
        if Tok.IsObject() then begin
            Obj := Tok.AsObject();

            // If it is a {$ref:"x"} object, resolve from index
            if Obj.Get('$ref', RefTok) then begin
                RefId := RefTok.AsValue().AsText();
                if (RefId <> '') and IdIndex.Get(RefId, RefJson) then begin
                    Obj.ReadFrom(RefJson);
                    exit(Obj);
                end;
            end;

            exit(Obj);
        end;

        exit(Obj); // empty
    end;    

    procedure GetText(Obj: JsonObject; PropertyName: Text; var IdIndex: Dictionary of [Text, Text]): Text
    var
        Tok: JsonToken;
        RefObj: JsonObject;
    begin
        if Obj.Get(PropertyName, Tok) then begin
            if Tok.AsValue().IsNull() then
                exit('');
            if Tok.IsValue() then
                exit(Tok.AsValue().AsText());
            if Tok.IsObject() then begin
                RefObj := ResolveToObject(Tok, IdIndex);
                if RefObj.Get(PropertyName, Tok) and Tok.IsValue() then
                    exit(Tok.AsValue().AsText());
            end;
        end;
        exit('');
    end;

    procedure GetDecimal(Obj: JsonObject; PropertyName: Text; var IdIndex: Dictionary of [Text, Text]): Decimal
    var
        Tok: JsonToken;
        D: Decimal;
        T: Text;
    begin
        if Obj.Get(PropertyName, Tok) then begin
            if Tok.AsValue().IsNull() then
                exit(0);

            if Tok.IsValue() then begin
                // handles JSON numbers without locale issues
                T := Tok.AsValue().AsText();
                Evaluate(D, T);
                exit(D);
            end;
        end;
        exit(0);
    end;    

    procedure GetInt(Obj: JsonObject; PropertyName: Text; var IdIndex: Dictionary of [Text, Text]): Integer
    var
        T: Text;
        I: Integer;
    begin
        T := GetText(Obj, PropertyName, IdIndex);
        if T = '' then
            exit(0);
        Evaluate(I, T);
        exit(I);
    end;
}
