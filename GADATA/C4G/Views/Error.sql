﻿









/*only ERRORPOST
-------------------------------------------------------------------------------------  */
CREATE VIEW [C4G].[Error]
AS
SELECT        
C.location
, C.controller_name AS Robotname
, 'C4G' AS Type, 'ERROR' AS Errortype
, ISNULL(H._timestamp, H.c_timestamp) AS timestamp
, L.error_number AS Logcode
, L.error_severity AS Severity
, L.error_text AS Logtekst
, NULL AS Downtime
, T.Vyear AS Year
, T.Vweek AS Week
, T.Vday AS day
, T.shift
, ISNULL(C4G.c_Appl.APPL,'NA') AS 'Object'
, ISNULL(C4G.c_Subgroup.Subgroup, 'NA') as 'Subgroup' 
, CAST(H.id AS int) AS idx
FROM            C4G.h_alarm AS H 
LEFT OUTER JOIN C4G.L_error AS L ON L.id = H.error_id 
LEFT OUTER JOIN c4g.c_controller AS C ON H.controller_id = C.id 
LEFT  JOIN C4G.c_Appl ON L.Appl_id = C4G.c_Appl.id 
LEFT  JOIN C4G.c_Subgroup ON L.Subgroup_id = C4G.c_Subgroup.id 
LEFT OUTER JOIN VOLVO.L_timeline AS T ON isnull(H._timestamp, H.c_timestamp) BETWEEN T.starttime AND T.endtime
WHERE        (H.error_is_alarm = 1)
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'C4G', @level1type = N'VIEW', @level1name = N'Error';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'C4G', @level1type = N'VIEW', @level1name = N'Error';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "H"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 135
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 135
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c_Appl (C4G)"
            Begin Extent = 
               Top = 6
               Left = 680
               Bottom = 101
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c_Subgroup (C4G)"
            Begin Extent = 
               Top = 6
               Left = 888
               Bottom = 101
               Right = 1058
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T"
            Begin Extent = 
               Top = 102
               Left = 680
               Bottom = 231
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
      ', @level0type = N'SCHEMA', @level0name = N'C4G', @level1type = N'VIEW', @level1name = N'Error';

