// Version 8.0.1
controladdin NetronicVSControlAddIn
{
    // RequestedHeight = 400;
    // MinimumHeight = 400;
    //MaximumHeight = 0;
    RequestedWidth = 600;
    MinimumWidth = 600;
    //MaximumWidth = 0;

    // Contrary to what Kauffmann suggests (https://www.kauffmann.nl/2019/02/01/controlling-the-size-of-a-control-add-in/), 
    // the VerticalStretch/Shrink must be set.
    // Otherwise VAPS gets into trouble (see also #2167)
    VerticalStretch = true;
    VerticalShrink = true;

    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts =
        'NetronicVSControlAddIn/NetronicVSWidget/blobstream.min.js',
        'NetronicVSControlAddIn/NetronicVSWidget/pdfkit.standalone.min.js',
        'NetronicVSControlAddIn/NetronicVSWidget/svgtopdfkit_0.1.8_patched.min.js',
        'NetronicVSControlAddIn/NetronicVSWidget/html2canvas.min.js',
        'NetronicVSControlAddIn/NetronicVSWidget/vscai-bundled.min.js',
        'NetronicVSControlAddIn/NetronicVSWidget/d3-context-menu.min.js';
    StyleSheets =
        'NetronicVSControlAddIn/NetronicVSWidget/nwaf-apptools.min.css',
        'NetronicVSControlAddIn/NetronicVSWidget/nwaf-table.min.css',
        'NetronicVSControlAddIn/NetronicVSWidget/nwaf-gantt.min.css',
        'NetronicVSControlAddIn/NetronicVSWidget/nwaf-rab.min.css',
        'NetronicVSControlAddIn/NetronicVSWidget/vscai-widget.min.css';
    StartupScript = 'NetronicVSControlAddIn/NetronicVSWidget/vscai-startup.js';

    event OnControlAddInReady();
    event OnRequestSettings(eventArgs: JsonObject);

    event OnClicked(eventArgs: JsonObject);
    event OnDoubleClicked(eventArgs: JsonObject);

    event OnDragStart(eventArgs: JsonObject);
    event OnDragEnd(eventArgs: JsonObject);

    event CanDrag(eventArgs: JsonObject);
    event OnDrop(eventArgs: JsonObject);

    event OnSelectionChanged(eventArgs: JsonObject);
    event OnCollapseStateChanged(eventArgs: JsonObject);
    event OnCurveCollapseStateChanged(eventArgs: JsonObject);
    event OnTableCellDefinitionWidthChanged(eventArgs: JsonObject);
    event OnTimeAreaViewParametersChanged(eventArgs: JsonObject);
    event OnVerticalScrollOffsetChanged(eventArgs: JsonObject);
    event OnRowSortingChangeRequested(eventArgs: JsonObject);

    event OnContextMenuItemClicked(eventArgs: JsonObject);
    event OnPing();

    event OnSaveAsPDFFinished();
    event OnSaveAsPDFProgress(eventArgs: JsonObject);

    event OnLogWarnings(eventArgs: JsonObject);
    event OnLogError(eventArgs: JsonObject);

    procedure SetSettings(settings: JsonObject);

    procedure FitFullTimeAreaIntoView();
    procedure FitTimeAreaIntoView(dtStart: DateTime; dtEnd: DateTime);
    procedure SetTimeResolutionForView(unit: Text; unitCount: Decimal; start: DateTime);

    procedure RemoveAll();
    procedure RemoveAllOfType(objectType: Integer);

    procedure Render();

    procedure ScrollToObject(objectType: Integer; objectID: Text; targetPositionInView: Integer; highlightingEnabled: Boolean);
    procedure ScrollToDate(dt: DateTime);
    procedure ScrollToDateWithOffset(dt: DateTime; offset: Text);
    procedure ScrollViewAreaHorizontally(viewArea: Integer; scrollPosition: Integer);
    procedure ScrollViewAreaVertically(viewArea: Integer; scrollPosition: Integer);

    procedure SelectObjects(objectType: Integer; objectIDs: JsonArray; visualType: Integer);
    procedure HighlightObjects(objectType: Integer; objectIDs: JsonArray; visualType: Integer);

    procedure SetCollapseStatesForEntityRows(newCollapseState: Integer; fromLevel: Integer; toLevel: Integer);
    procedure SetCollapseStatesForRows(viewType: Integer; newCollapseState: Integer; fromLevel: Integer; toLevel: Integer; collapseStateTargets: Integer);

    procedure SaveAsPDF(fileName: Text; options: JsonObject);
    procedure CancelSaveAsPDF();

    procedure About();

    procedure AddActivities(activities: JsonArray);
    procedure UpdateActivities(activities: JsonArray);
    procedure RemoveActivities(activitiesOrIDs: JsonArray);

    procedure AddAllocations(allocations: JsonArray);
    procedure UpdateAllocations(allocations: JsonArray);
    procedure RemoveAllocations(allocationsOrIDs: JsonArray);

    procedure AddCalendars(calendars: JsonArray);
    procedure UpdateCalendars(calendars: JsonArray);
    procedure RemoveCalendars(calendarsOrIDs: JsonArray);

    procedure AddCurves(curves: JsonArray);
    procedure UpdateCurves(curves: JsonArray);
    procedure RemoveCurves(curvesOrIDs: JsonArray);

    procedure AddResources(resources: JsonArray);
    procedure UpdateResources(resources: JsonArray);
    procedure RemoveResources(resourcesOrIDs: JsonArray);

    procedure AddLinks(links: JsonArray);
    procedure UpdateLinks(links: JsonArray);
    procedure RemoveLinks(linksOrIDs: JsonArray);

    procedure AddEntities(entities: JsonArray);
    procedure UpdateEntities(entities: JsonArray);
    procedure RemoveEntities(entitiesOrIDs: JsonArray);

    procedure AddSymbols(symbols: JsonArray);
    procedure UpdateSymbols(symbols: JsonArray);
    procedure RemoveSymbols(symbolsOrIDs: JsonArray);

    procedure AddContextMenus(contextMenus: JsonArray);
    procedure UpdateContextMenus(contextMenus: JsonArray);
    procedure RemoveContextMenus(contextMenusOrIDs: JsonArray);

    procedure AddCalendarGrids(calendarGrids: JsonArray); // deprecated, Hamlet-only
    procedure UpdateCalendarGrids(calendarGrids: JsonArray); // deprecated, Hamlet-only
    procedure RemoveCalendarGrids(calendarGridsOrIDs: JsonArray); // deprecated, Hamlet-only

    procedure AddDateLines(dateLines: JsonArray);
    procedure UpdateDateLines(dateLines: JsonArray);
    procedure RemoveDateLines(dateLines: JsonArray);

    procedure AddTooltipTemplates(tooltipTemplates: JsonArray);
    procedure UpdateTooltipTemplates(tooltipTemplates: JsonArray);
    procedure RemoveTooltipTemplates(tooltipTemplatesOrIDs: JsonArray);

    procedure AddTableRowDefinitions(tableRowDefinitions: JsonArray);
    procedure UpdateTableRowDefinitions(tableRowDefinitionss: JsonArray);
    procedure RemoveTableRowDefinitions(tableRowDefinitionsOrIDs: JsonArray);

    procedure AddPeriodHighlighters(periodHighlighters: JsonArray);
    procedure UpdatePeriodHighlighters(periodHighlighters: JsonArray);
    procedure RemovePeriodHighlighters(periodHighlightersOrIDs: JsonArray);

    procedure AddHierarchySupplementaryDefinitions(hsds: JsonArray);
    procedure UpdateHierarchySupplementaryDefinitions(hsds: JsonArray);
    procedure RemoveHierarchySupplementaryDefinitions(hsdsOrIDs: JsonArray);

    procedure AddSkills(skills: JsonArray);
    procedure UpdateSkills(skills: JsonArray);
    procedure RemoveSkills(skillsOrIDs: JsonArray);

    procedure SetResourcePropertiesForSkill(resourcePropertiesObjects: JsonArray);
}
