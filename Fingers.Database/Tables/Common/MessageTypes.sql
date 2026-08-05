USE [ChatFingers]
GO

/****** Object:  Table [common].[MessageTypes]    Script Date: 05-08-2026 11:22:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [common].[MessageTypes](
	[MessageTypeId] [tinyint] NOT NULL,
	[TypeCode] [nvarchar](30) NOT NULL,
	[TypeName] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MessageTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [common].[MessageTypes] ADD  CONSTRAINT [DF_common_MessageTypes_CreatedOn]  DEFAULT (sysutcdatetime()) FOR [CreatedOn]
GO


