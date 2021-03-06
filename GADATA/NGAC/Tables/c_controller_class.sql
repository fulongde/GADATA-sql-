﻿CREATE TABLE [NGAC].[c_controller_class] (
    [id]                                INT           IDENTITY (1, 1) NOT NULL,
    [name]                              VARCHAR (100) NOT NULL,
    [doConnect]                         BIT           NOT NULL,
    [evStateChange]                     INT           NOT NULL,
    [evOperatingModeChange]             INT           NOT NULL,
    [evConnectionChange]                INT           NOT NULL,
    [evExecutionStatus]                 INT           NOT NULL,
    [evExecutionStatusTRob1]            INT           NOT NULL,
    [evBackupCompleted]                 INT           NOT NULL,
    [evDataResolveChange]               INT           NOT NULL,
    [evExecutionCycleChange]            INT           NOT NULL,
    [evTaskEnabledChange]               INT           NOT NULL,
    [evMasterChange]                    INT           NOT NULL,
    [evMotionPointerTRob1Change]        INT           NOT NULL,
    [evProgramPointerTRob1Change]       INT           NOT NULL,
    [evMotionPointerTRob1ManualChange]  INT           NOT NULL,
    [evProgramPointerTRob1ManualChange] INT           NOT NULL,
    [cVariableMask]                     INT           NOT NULL,
    [cVariableSearchMask]               INT           NOT NULL,
    [cDeviceInfoMask]                   INT           NOT NULL,
    [cCSVLogMask]                       INT           NOT NULL,
    [cJobMask]                          INT           NOT NULL,
    [logCategoryMask]                   INT           NOT NULL,
    [handleHSocket]                     BIT           NOT NULL,
    [Username]                          VARCHAR (50)  NOT NULL,
    [Password]                          VARCHAR (50)  NOT NULL,
    [setClock]                          INT           NOT NULL,
    [evLogMessageAction]                INT           NOT NULL,
    [cPJVEventMask]                     INT           NOT NULL,
    [cPJVActionMask]                    INT           NOT NULL,
    [cErrorMask]                        INT           NOT NULL,
    CONSTRAINT [PK_c_controller_class_1] PRIMARY KEY CLUSTERED ([id] ASC)
);



