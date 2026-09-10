page 50450 "VIC Lot Availability"
{
    PageType = Card;
    Caption = 'Lot Availability';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Input)
            {
                Caption = 'Inventory Selection';

                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    TableRelation = Item."No.";

                    trigger OnValidate()
                    begin
                        ClearResults();
                    end;
                }

                field(LotNo; LotNo)
                {
                    ApplicationArea = All;
                    Caption = 'Lot No.';

                    trigger OnValidate()
                    begin
                        ClearResults();
                    end;
                }

                field(LocationCode; LocationCode)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location.Code;

                    trigger OnValidate()
                    begin
                        BinCode := '';
                        ClearResults();
                    end;
                }

                field(BinCode; BinCode)
                {
                    ApplicationArea = All;
                    Caption = 'Bin Code';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Bin: Record Bin;
                    begin
                        if LocationCode = '' then
                            Error('Enter a Location Code before selecting a Bin Code.');

                        Bin.SetRange("Location Code", LocationCode);

                        if Page.RunModal(Page::"Bin List", Bin) = Action::LookupOK then begin
                            BinCode := Bin.Code;
                            ClearResults();
                            exit(true);
                        end;

                        exit(false);
                    end;

                    trigger OnValidate()
                    var
                        Bin: Record Bin;
                    begin
                        if BinCode <> '' then begin
                            Bin.SetRange("Location Code", LocationCode);
                            Bin.SetRange(Code, BinCode);

                            if not Bin.FindFirst() then
                                Error(
                                    'Bin %1 does not exist at location %2.',
                                    BinCode,
                                    LocationCode);
                        end;

                        ClearResults();
                    end;
                }
            }

            group(Results)
            {
                Caption = 'Availability';

                field(BinQtyOnHand; BinQtyOnHand)
                {
                    ApplicationArea = All;
                    Caption = 'Bin Qty. On Hand';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }

                field(LotQtyOnHand; LotQtyOnHand)
                {
                    ApplicationArea = All;
                    Caption = 'Lot Qty. On Hand';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }

                field(LotQtyReserved; LotQtyReserved)
                {
                    ApplicationArea = All;
                    Caption = 'Lot Qty. Reserved';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }

                field(LotQtyAvailable; LotQtyAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Lot Qty. Available';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculate)
            {
                ApplicationArea = All;
                Caption = 'Calculate';
                ToolTip = 'Calculate inventory availability for the selected item, lot, location, and bin.';

                trigger OnAction()
                begin
                    CalculateAvailability();
                end;
            }
        }
    }

    var
        LotAvailabilityMgt: Codeunit "VIC Lot Availability Mgt.";

        ItemNo: Code[20];
        LotNo: Code[50];
        LocationCode: Code[10];
        BinCode: Code[20];

        BinQtyOnHand: Decimal;
        LotQtyOnHand: Decimal;
        LotQtyReserved: Decimal;
        LotQtyAvailable: Decimal;


    local procedure CalculateAvailability()
    begin
        LotAvailabilityMgt.GetLotAvailability(
            ItemNo,
            LotNo,
            LocationCode,
            BinCode,
            BinQtyOnHand,
            LotQtyOnHand,
            LotQtyReserved,
            LotQtyAvailable);
    end;


    local procedure ClearResults()
    begin
        Clear(BinQtyOnHand);
        Clear(LotQtyOnHand);
        Clear(LotQtyReserved);
        Clear(LotQtyAvailable);
    end;
}