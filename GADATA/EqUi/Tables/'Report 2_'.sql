﻿CREATE TABLE [EqUi].['Report 2$'] (
    [WorkOrder Number]                                        NVARCHAR (255) NULL,
    [WorkOrder Description]                                   NVARCHAR (255) NULL,
    [Location]                                                NVARCHAR (255) NULL,
    [Asset Number]                                            NVARCHAR (255) NULL,
    [Status]                                                  NVARCHAR (255) NULL,
    [Work Type]                                               NVARCHAR (255) NULL,
    [PM Number]                                               NVARCHAR (255) NULL,
    [JP Number]                                               NVARCHAR (255) NULL,
    [Owner Group]                                             NVARCHAR (255) NULL,
    [Supervisor]                                              NVARCHAR (255) NULL,
    [Duration]                                                FLOAT (53)     NULL,
    [WO Priority]                                             FLOAT (53)     NULL,
    [Long Description (WO)#Long Description Text]             NVARCHAR (MAX) NULL,
    [Person DisplayName]                                      NVARCHAR (255) NULL,
    [Regularhrs]                                              FLOAT (53)     NULL,
    [Failure Remark Description]                              NVARCHAR (255) NULL,
    [Actual Material Cost]                                    FLOAT (53)     NULL,
    [Changedate]                                              DATETIME       NULL,
    [Failure Remark (Long Description)#Long Description Text] NVARCHAR (MAX) NULL,
    [Report Date]                                             DATETIME       NULL,
    [Reported By]                                             NVARCHAR (255) NULL,
    [Parent]                                                  NVARCHAR (255) NULL,
    [id]                                                      INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_'Report 2$'] PRIMARY KEY CLUSTERED ([id] ASC)
);
