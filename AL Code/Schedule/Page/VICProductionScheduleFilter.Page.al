page 50411 VICProductionScheduleFilter
{
    Caption = 'Filter Production Schedule';
    DataCaptionExpression = '';
    PageType = StandardDialog;
    SourceTable = VICScheduleFilter;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(ScheduleSettings)
            {
                Caption = 'Filters';
                field(OrderNumber; Rec.OrderNumber)
                {
                    Caption = 'Batch or Planned Order Number';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;

                    // trigger OnValidate()
                    // begin
                    //     Rec.Modify()
                    // end;
                }
                field(Formula; Rec.Formula)
                {
                    Caption = 'Formula';
                    ApplicationArea = All;
                    Visible = true;
                    Editable = true;

                    // trigger OnValidate()
                    // begin
                    //     Rec.Modify()
                    // end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FindFirst();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // Rec.Modify();
    end;
}
