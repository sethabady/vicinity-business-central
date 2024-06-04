page 50420 VICDoDrillbacks
{
    // PageType = List;
    PageType = Card;
    // ApplicationArea = All;
    SourceTable = VICDrillback;

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty() then
            Error('Drillback to Vicinty page has not been defined');
    end;

    trigger OnAfterGetRecord()
    begin
        // Message(Rec."Vicinity Screen" + '||' + Rec."Drillback Hyperlink");
        Hyperlink(Rec."Drillback Hyperlink");
        Close();
    end;
}