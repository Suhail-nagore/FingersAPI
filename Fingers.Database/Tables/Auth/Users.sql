/*
==============================================================================
Project      : Fingers
Module       : Authentication
Object Type  : Table
Object Name  : Users
Author       : Mohd Suhail
Description  : Stores registered users.
==============================================================================
*/

USE [ChatFingers]
GO

/****** Object:  Table [auth].[Users]    Script Date: 05-08-2026 11:23:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [auth].[Users](
	[UserId] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](320) NOT NULL,
	[PasswordHash] [nvarchar](max) NOT NULL,
	[UserStatusId] [tinyint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[CreatedByUserId] [bigint] NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[ModifiedByUserId] [bigint] NULL,
	[ProfilePictureUrl] [nvarchar](500) NULL,
	[About] [nvarchar](250) NULL,
	[LastSeenOn] [datetime2](7) NULL,
	[IsProfilePrivate] [bit] NOT NULL,
 CONSTRAINT [PK_auth_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_auth_Users_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_auth_Users_Username] UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [auth].[Users] ADD  CONSTRAINT [DF_auth_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [auth].[Users] ADD  CONSTRAINT [DF_auth_Users_CreatedOn]  DEFAULT (sysutcdatetime()) FOR [CreatedOn]
GO

ALTER TABLE [auth].[Users] ADD  CONSTRAINT [DF_auth_Users_IsProfilePrivate]  DEFAULT ((0)) FOR [IsProfilePrivate]
GO

ALTER TABLE [auth].[Users]  WITH CHECK ADD  CONSTRAINT [FK_auth_Users_UserStatusId_common_UserStatuses] FOREIGN KEY([UserStatusId])
REFERENCES [common].[UserStatuses] ([UserStatusId])
GO

ALTER TABLE [auth].[Users] CHECK CONSTRAINT [FK_auth_Users_UserStatusId_common_UserStatuses]
GO


