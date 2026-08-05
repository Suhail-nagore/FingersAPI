USE [ChatFingers]
GO

/****** Object:  Table [common].[ConversationTypes]    Script Date: 05-08-2026 11:22:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [common].[ConversationTypes](
	[ConversationTypeId] [tinyint] NOT NULL,
	[TypeCode] [nvarchar](30) NOT NULL,
	[TypeName] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ConversationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [common].[ConversationTypes] ADD  CONSTRAINT [DF_common_ConversationTypes_CreatedOn]  DEFAULT (sysutcdatetime()) FOR [CreatedOn]
GO


