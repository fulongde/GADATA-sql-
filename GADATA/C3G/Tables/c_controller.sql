﻿CREATE TABLE [C3G].[c_controller] (
    [id]                        INT           IDENTITY (1, 1) NOT NULL,
    [controller_name]           VARCHAR (50)  NULL,
    [sys_id]                    VARCHAR (20)  NULL,
    [location]                  VARCHAR (256) NULL,
    [ipaddress]                 VARCHAR (32)  NULL,
    [username]                  VARCHAR (32)  NULL,
    [password]                  VARCHAR (32)  NULL,
    [reconnect]                 BIT           NULL,
    [log_flag]                  INT           NULL,
    [enable_bit]                INT           NULL,
    [variable_mask]             INT           NULL,
    [statement_mask]            INT           NULL,
    [error_no_log_mask]         INT           NULL,
    [alarm_monitor]             BIT           NULL,
    [state_monitor]             INT           NULL,
    [state_filter]              INT           NULL,
    [poll_rate]                 INT           NULL,
    [poll_not_saved]            BIT           NULL,
    [poll_error_file_list]      BIT           NULL,
    [poll_action_file_list]     BIT           NULL,
    [read_sys]                  INT           NULL,
    [generation]                INT           NULL,
    [ownership]                 VARCHAR (256) NULL,
    [Plant]                     VARCHAR (3)   NULL,
    [Area]                      VARCHAR (25)  NULL,
    [SubArea]                   VARCHAR (25)  NULL,
    [event_mask]                INT           NULL,
    [record_mask]               INT           NULL,
    [error_trigger_mask]        INT           NULL,
    [prog_info_ign_mask]        INT           NULL,
    [production_monitor]        INT           NULL,
    [poll_clock]                INT           NULL,
    [rt_flags]                  INT           NULL,
    [description]               VARCHAR (256) NULL,
    [swversion]                 VARCHAR (50)  NULL,
    [keycode]                   INT           NULL,
    [ipcb_flags]                INT           NULL,
    [LocationTree]              VARCHAR (MAX) NULL,
    [Assetnum]                  VARCHAR (MAX) NULL,
    [ProductionTeam]            VARCHAR (MAX) NULL,
    [ResponsibleTechnicianTeam] VARCHAR (50)  NULL,
    [ResponsibleProductionTeam] VARCHAR (50)  NULL,
    [ClassificationTree]        VARCHAR (MAX) NULL,
    [CLassificationId]          VARCHAR (MAX) NULL,
    [pjv_action_mask]           INT           NULL,
    [pjv_event_mask]            INT           NULL,
    CONSTRAINT [PK_c_controller1] PRIMARY KEY CLUSTERED ([id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [_dta_index_c_controller_23_1193679946__K1_K2]
    ON [C3G].[c_controller]([id] ASC, [controller_name] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_c_controller_23_1193679946__K2_K4_K23_1_24_25_26]
    ON [C3G].[c_controller]([controller_name] ASC, [location] ASC, [ownership] ASC)
    INCLUDE([Area], [id], [Plant], [SubArea]);


GO


