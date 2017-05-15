﻿CREATE TABLE [C4G].[rt_rec_data] (
    [id]                INT      IDENTITY (1, 1) NOT NULL,
    [rt_rec_group_id]   INT      NULL,
    [c_rec_variable_id] INT      NULL,
    [_timestamp]        DATETIME NULL,
    [axis]              INT      NULL,
    [status]            INT      NULL,
    [_Min]              REAL     NULL,
    [_Max]              REAL     NULL,
    [_Range]            REAL     NULL,
    [_Sum]              REAL     NULL,
    [_Sum_Abs]          REAL     NULL,
    [_Delta_Sum]        REAL     NULL,
    [_Delta_Sum_Abs]    REAL     NULL,
    [_Delta_min]        REAL     NULL,
    [_Delta_max]        REAL     NULL,
    [_Delta_Area]       REAL     NULL,
    [_Delta_Area_Abs]   REAL     NULL,
    [_Length]           REAL     NULL,
    [_Area]             REAL     NULL,
    [_Area_Abs]         REAL     NULL,
    [_SDev]             REAL     NULL,
    [_Variance]         REAL     NULL,
    [_Inversions]       INT      NULL,
    [_Count]            INT      NULL,
    [Iterval_Below]     INT      NULL,
    [Iterval_0]         INT      NULL,
    [Iterval_1]         INT      NULL,
    [Iterval_2]         INT      NULL,
    [Iterval_3]         INT      NULL,
    [Iterval_4]         INT      NULL,
    [Iterval_5]         INT      NULL,
    [Iterval_6]         INT      NULL,
    [Iterval_7]         INT      NULL,
    [Iterval_8]         INT      NULL,
    [Iterval_9]         INT      NULL,
    [Iterval_Above]     INT      NULL,
    [time_taken]        INT      NULL,
    [_Mean]             REAL     NULL,
    [controller_id]     INT      NULL,
    [idle_time]         INT      NULL,
    [active_time]       INT      NULL,
    [_RMS]              REAL     NULL,
    [_When_Min]         INT      NULL,
    [_When_Max]         INT      NULL,
    [_When_Delta_Min]   INT      NULL,
    [_When_Delta_Max]   INT      NULL,
    CONSTRAINT [PK_rt_rec_data] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rt_rec_data_c_controller] FOREIGN KEY ([controller_id]) REFERENCES [C4G].[c_controller] ([id]),
    CONSTRAINT [FK_rt_rec_data_c_rec_variable] FOREIGN KEY ([c_rec_variable_id]) REFERENCES [C4G].[c_rec_variable] ([id]),
    CONSTRAINT [FK_rt_rec_data_rt_rec_group] FOREIGN KEY ([rt_rec_group_id]) REFERENCES [C4G].[rt_rec_group] ([id])
);






