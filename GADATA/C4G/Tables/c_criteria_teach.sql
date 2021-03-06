﻿CREATE TABLE [C4G].[c_criteria_teach] (
    [id]                  INT      IDENTITY (1, 1) NOT NULL,
    [axis]                INT      NULL,
    [shift_mask]          INT      NULL,
    [c_criteria_setup_id] INT      NULL,
    [controller_id]       INT      NULL,
    [teach_if1]           REAL     NULL,
    [teach_sd_if1]        REAL     NULL,
    [teach_if2]           REAL     NULL,
    [teach_sd_if2]        REAL     NULL,
    [teach_if3]           REAL     NULL,
    [teach_sd_if3]        REAL     NULL,
    [teach_when1]         REAL     NULL,
    [teach_sd_when1]      REAL     NULL,
    [teach_when2]         REAL     NULL,
    [teach_sd_when2]      REAL     NULL,
    [teach_when3]         REAL     NULL,
    [teach_sd_when3]      REAL     NULL,
    [isDeleted]           INT      NULL,
    [run_mode]            INT      NULL,
    [keycode]             INT      NULL,
    [_timestamp]          DATETIME NULL,
    CONSTRAINT [PK_c_criteria_teach] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_c_criteria_teach_c_controller_id] FOREIGN KEY ([controller_id]) REFERENCES [C4G].[c_controller] ([id]),
    CONSTRAINT [FK_c_criteria_teach_c_criteria_setup_id] FOREIGN KEY ([c_criteria_setup_id]) REFERENCES [C4G].[c_criteria_setup] ([id])
);

