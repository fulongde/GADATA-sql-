﻿CREATE TABLE [dbo].[UltralogInspections] (
    [ID]                INT        IDENTITY (1, 1) NOT NULL,
    [InspectionPlanID]  INT        NOT NULL,
    [SpotID]            INT        NOT NULL,
    [InspectorComment]  NCHAR (30) NULL,
    [BodyNbr]           INT        NOT NULL,
    [InspectorID]       INT        NOT NULL,
    [InspectionTime]    DATETIME   NOT NULL,
    [IndexOfTestSeq]    INT        NOT NULL,
    [Loose]             BIT        NOT NULL,
    [OK]                BIT        NOT NULL,
    [SmallNugget]       BIT        NOT NULL,
    [StickWeld]         BIT        NOT NULL,
    [BadTroughWeld]     BIT        NOT NULL,
    [StationID]         INT        NOT NULL,
    [MeasuredThickness] FLOAT (53) NULL,
    [MinIdentation]     FLOAT (53) NULL,
    [TotalThickness]    FLOAT (53) NULL,
    [PlanLenght]        INT        NULL,
    CONSTRAINT [FK_UltralogInspections_Inspectionplan] FOREIGN KEY ([InspectionPlanID]) REFERENCES [dbo].[Inspectionplan] ([ID]),
    CONSTRAINT [FK_UltralogInspections_Spot] FOREIGN KEY ([SpotID]) REFERENCES [dbo].[Spot] ([ID]),
    CONSTRAINT [FK_UltralogInspections_UltralogStations] FOREIGN KEY ([StationID]) REFERENCES [dbo].[UltralogStations] ([ID]),
    CONSTRAINT [FK_UltralogInspections_Users] FOREIGN KEY ([InspectorID]) REFERENCES [dbo].[Users] ([ID])
);



