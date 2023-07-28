USE [AdventureWorks2022]
GO
/****** Object:  Table [dbo].[ALL_POSSIBLE_RELATIONSHIPS]    Script Date: 6/3/2023 1:38:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ALL_POSSIBLE_RELATIONSHIPS](
	[tbl_name] [nvarchar](max) NULL,
	[col_name] [nvarchar](max) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TableSchemaName] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SCHEMA_CONCATENATE_DUPLICATE_KEY_COLUMNS]    Script Date: 6/3/2023 1:38:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCHEMA_CONCATENATE_DUPLICATE_KEY_COLUMNS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_Table_Name] [nvarchar](max) NULL,
	[Child_Table_Name] [nvarchar](max) NULL,
	[Foreign_Key_Constraint_Name] [nvarchar](max) NULL,
	[Parent_Column_List] [nvarchar](max) NULL,
	[Referenced_Column_List] [nvarchar](max) NULL,
	[Total_FKs_Used] [int] NULL,
	[TableSchemaName] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SCHEMA_TABLES_WITH_DUPLICATE_KEY_COLUMNS]    Script Date: 6/3/2023 1:38:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCHEMA_TABLES_WITH_DUPLICATE_KEY_COLUMNS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_Table_Name] [nvarchar](max) NULL,
	[Child_Table_Name] [nvarchar](max) NULL,
	[Foreign_Key_Constraint_Name] [nvarchar](max) NULL,
	[Parent_Column] [nvarchar](max) NULL,
	[Referenced_Column] [nvarchar](max) NULL,
	[Total FKs] [varchar](max) NULL,
	[TableSchemaName] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SCHEMA_VERBOSE]    Script Date: 6/3/2023 1:38:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCHEMA_VERBOSE](
	[Parent_Table_Name] [nvarchar](max) NULL,
	[Child_Table_Name] [nvarchar](max) NULL,
	[Foreign_Key_Constraint_Name] [nvarchar](max) NULL,
	[Referenced_Column] [nvarchar](max) NULL,
	[Parent_Column] [nvarchar](max) NULL,
	[Total_FKs_Used] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
