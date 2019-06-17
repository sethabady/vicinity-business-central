page 50149 "Vicinity Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Vicinity Setup";
    Caption = 'Vicinity Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Vicinity Enabled"; "Vicinity Enabled")
                {
                    ApplicationArea = All;

                }
                field("Gen. Journal Batch"; "Gen. Journal Batch")
                {
                    ApplicationArea = All;

                }

                field("Item Journal Batch"; "Item Journal Batch")
                {
                    ApplicationArea = All;

                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;

                }
                field("Warehousing Enabled"; "Warehousing Enabled")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Warehouse Journal Batch"; "Warehouse Journal Batch")
                {
                    Visible = false;
                    ApplicationArea = All;

                }

            }
        }
    }
}