// pageextension 50220 VICDoDrillbacks extends "Whse. Basic Role Center"
// {
//     Actions
//     {
//         addbefore("Sales & Purchases")
//         {
//             group(Vicinity)
//             {
//                 group(ProductionControl)
//                 {
//                     Caption = 'Production Control';
//                     Action(BatchEntry)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Batch Entry';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(1));
//                     }
//                     Action(CreateBatches)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Create Batches';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(2));
//                     }
//                     Action(EndItemCompletions)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'End-Item Completions';
//                         RunObject = page VICBatchList;
//                     }
//                 }
//                 group(ProductionPlanning)
//                 {
//                     Caption = 'Production Planning';
//                     Action(ProductionSchedule)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Production Schedule';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(3));
//                     }
//                     Action(ProductionCalendar)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Production Calendar';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(4));
//                     }
//                     Action(PlanningWorkbench)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Planning Workbench';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(5));
//                     }
//                 }
//                 group(Quality)
//                 {
//                     Caption = 'Quality';
//                     Action(QualitySampleEntry)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Quality Sample Entry';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(6));
//                     }
//                     Action(BatchQualityInquiry)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Batch Quality Inquiry';
//                         RunObject = page VICDoDrillbacks;
//                         RunPageView = WHERE("Drillback ID" = filter(7));
//                     }
//                 }
//                 Action(LotTraceInquiry)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Lot Trace Inquiry';
//                     RunObject = page VICDoDrillbacks;
//                     RunPageView = WHERE("Drillback ID" = filter(8));
//                 }
//                 Action(VicinityView)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'VicinityView';
//                     RunObject = page VICDoDrillbacks;
//                     RunPageView = WHERE("Drillback ID" = filter(0));
//                 }
//             }
//         }
//     }
// }
