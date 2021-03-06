﻿CREATE TABLE [NGAC].[rt_studErrLog] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [rt_csv_file_id] INT           NULL,
    [Date Time]      DATETIME      NULL,
    [Tool Name]      VARCHAR (MAX) NULL,
    [SetUp No]       INT           NULL,
    [Tool Diff X]    FLOAT (53)    NULL,
    [Tool Diff Y]    FLOAT (53)    NULL,
    [Tool Diff Z]    FLOAT (53)    NULL,
    [Tool Tol X]     FLOAT (53)    NULL,
    [Tool Tol Y]     FLOAT (53)    NULL,
    [Tool Tol Z]     FLOAT (53)    NULL,
    [Old TCP X]      FLOAT (53)    NULL,
    [Old TCP Y]      FLOAT (53)    NULL,
    [Old TCP Z]      FLOAT (53)    NULL,
    [New TCP X]      FLOAT (53)    NULL,
    [New TCP Y]      FLOAT (53)    NULL,
    [New TCP Z]      FLOAT (53)    NULL,
    [Action]         VARCHAR (MAX) NULL,
    [TargetID]       VARCHAR (MAX) NULL,
    [Prog No]        VARCHAR (MAX) NULL,
    [Alarm Nr]       VARCHAR (MAX) NULL,
    [Text_1]         VARCHAR (MAX) NULL,
    [Text_2]         VARCHAR (MAX) NULL,
    [Text_3]         VARCHAR (MAX) NULL,
    [Text_4]         VARCHAR (MAX) NULL,
    [Text_5]         VARCHAR (MAX) NULL,
    [Text_6]         VARCHAR (MAX) NULL,
    [Text_7]         VARCHAR (MAX) NULL,
    [Text_8]         VARCHAR (MAX) NULL,
    [Text_9]         VARCHAR (MAX) NULL,
    [Text_10]        VARCHAR (MAX) NULL,
    [Text_11]        VARCHAR (MAX) NULL,
    [_timestamp]     DATETIME      NULL,
    CONSTRAINT [PK_rt_studErrLog] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rt_studErrLog_rt_csv_file] FOREIGN KEY ([rt_csv_file_id]) REFERENCES [NGAC].[rt_csv_file] ([id])
);

