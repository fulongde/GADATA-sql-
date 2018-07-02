﻿CREATE TABLE [STO].[rt_error] (
    [NID_ALARM_DATA] FLOAT (53)    NULL,
    [ALARMSOURCE]    VARCHAR (MAX) NULL,
    [ALARMOBJECT]    VARCHAR (MAX) NULL,
    [ALARMCOMMENT]   VARCHAR (MAX) NULL,
    [ALARMSEVERITY]  VARCHAR (MAX) NULL,
    [GEOLOACTION]    VARCHAR (MAX) NULL,
    [ALARMSTATUS]    BIT           NULL,
    [ALARMTIMESTAMP] VARCHAR (MAX) NULL,
    [SUBZONENAME]    VARCHAR (MAX) NULL,
    [FCOMPLETE]      NCHAR (1)     NULL,
    [CHANGETS]       DATETIME      NULL,
    [StoTable]       VARCHAR (50)  NULL,
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_rt_error] PRIMARY KEY CLUSTERED ([id] ASC)
);



