enum 50183 PlanningItemQuantityType
{
    Extensible = false;
    value(0; "BatchEndItem") { Caption = 'End Item'; }
    value(1; "BatchEndItemBOM") {Caption = 'Bill of Material'; }
    value(2; "BatchIngredient") { Caption = 'Ingredient'; }
    value(3; "BatchByCoProduct") { Caption = 'By or Co-Product'; }
    value(4; "FirmPlannedOrder") {Caption = 'Firm Planned Order'; }
    value(5; "UnfirmedPlannedOrder") {Caption = 'Unfirmed Firm Planned Order'; }
}
