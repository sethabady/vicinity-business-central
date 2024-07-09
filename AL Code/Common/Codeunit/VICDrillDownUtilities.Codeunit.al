codeunit 50412 VICDrillDownUtilities
{
    procedure GetDrillDownHyperlink(QuantityType: Enum PlanningItemQuantityType; FacilityId: Text; DocumentNumber: Text): Text
    var 
        HyperLink: Text;
        VicinityDrillback: Record VICDrillback;
    begin
        VicinityDrillback.SetCurrentKey("Drillback ID");
        if ((QuantityType = QuantityType::FirmPlannedOrder) or (QuantityType = QuantityType::UnfirmedPlannedOrder)) then begin 
            VicinityDrillback.SetRange("Drillback ID", DrillDownType::PlannedOrders.AsInteger());
            if VicinityDrillback.Find('-') then begin
                HyperLink := VicinityDrillback."Drillback Hyperlink" + '&FacilityID=' + FacilityId + '&PlannedOrderNumber=' + DocumentNumber;
            end
        end
        else begin 
            VicinityDrillback.SetRange("Drillback ID", DrillDownType::BatchEntry.AsInteger());
            if VicinityDrillback.Find('-') then begin
                HyperLink := VicinityDrillback."Drillback Hyperlink" + '&FacilityID=' + FacilityId + '&BatchNumber=' + DocumentNumber;
            end
        end;
        Exit(HyperLink);       
    end;
}