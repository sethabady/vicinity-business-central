page 50335 "Facility Lookup"
{
    PageType = List;
    SourceTable = VICFacilityTemp;
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(FacilityId; Rec.FacilityId)
                {
                    ApplicationArea = All;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInit()
    begin
        SelectedFacilityId := '';
        Rec := VICFacilityTemp;
    end;

    protected var
        SelectedFacilityId: Text[15];
        VICFacilityTemp: Record VICFacilityTemp;

    procedure SetSelectedFacilityId(FacilityId: Text[15])
    begin
        SelectedFacilityId := FacilityId;
    end;

    procedure SetVICFacilityTemp(var TempVICFacility: Record VICFacilityTemp)
    begin 
        VICFacilityTemp := TempVICFacility;
    end;
}