USE [ChatFingers]
GO

CREATE OR ALTER PROCEDURE [chat].[MessageAttachmentsCreate]
(
    @UploadedByUserId BIGINT,

    @PublicId NVARCHAR(500),

    @FileName NVARCHAR(255),

    @OriginalFileName NVARCHAR(255),

    @ContentType NVARCHAR(100),

    @FileExtension NVARCHAR(20),

    @FileSize BIGINT,

    @StoragePath NVARCHAR(1000),

    @ThumbnailPath NVARCHAR(1000) = NULL,

    @DurationInSeconds INT = NULL,

    @Width INT = NULL,

    @Height INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        ----------------------------------------------------------------------
        -- Validate Uploaded User
        ----------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM auth.Users
            WHERE UserId = @UploadedByUserId
              AND IsActive = 1
        )
        BEGIN
            THROW 50001, 'Invalid user.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate PublicId
        ----------------------------------------------------------------------

        IF @PublicId IS NULL
           OR LTRIM(RTRIM(@PublicId)) = ''
        BEGIN
            THROW 50002, 'PublicId is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate File Name
        ----------------------------------------------------------------------

        IF @FileName IS NULL
           OR LTRIM(RTRIM(@FileName)) = ''
        BEGIN
            THROW 50003, 'FileName is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate Original File Name
        ----------------------------------------------------------------------

        IF @OriginalFileName IS NULL
           OR LTRIM(RTRIM(@OriginalFileName)) = ''
        BEGIN
            THROW 50004, 'OriginalFileName is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate Content Type
        ----------------------------------------------------------------------

        IF @ContentType IS NULL
           OR LTRIM(RTRIM(@ContentType)) = ''
        BEGIN
            THROW 50005, 'ContentType is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate File Extension
        ----------------------------------------------------------------------

        IF @FileExtension IS NULL
           OR LTRIM(RTRIM(@FileExtension)) = ''
        BEGIN
            THROW 50006, 'FileExtension is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate File Size
        ----------------------------------------------------------------------

        IF @FileSize IS NULL OR @FileSize <= 0
        BEGIN
            THROW 50007, 'FileSize must be greater than zero.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate Storage Path
        ----------------------------------------------------------------------

        IF @StoragePath IS NULL
           OR LTRIM(RTRIM(@StoragePath)) = ''
        BEGIN
            THROW 50008, 'StoragePath is required.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate Dimensions
        --
        -- Width and Height are optional because they are not applicable
        -- to every media type.
        ----------------------------------------------------------------------

        IF @Width IS NOT NULL AND @Width <= 0
        BEGIN
            THROW 50009, 'Width must be greater than zero.', 1;
        END;


        IF @Height IS NOT NULL AND @Height <= 0
        BEGIN
            THROW 50010, 'Height must be greater than zero.', 1;
        END;


        ----------------------------------------------------------------------
        -- Validate Duration
        ----------------------------------------------------------------------

        IF @DurationInSeconds IS NOT NULL
           AND @DurationInSeconds < 0
        BEGIN
            THROW 50011, 'DurationInSeconds cannot be negative.', 1;
        END;


        ----------------------------------------------------------------------
        -- Prevent Duplicate PublicId
        --
        -- A Cloudinary PublicId identifies the uploaded asset.
        -- We don't want the same asset registered multiple times.
        ----------------------------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM chat.MessageAttachments
            WHERE PublicId = @PublicId
        )
        BEGIN
            THROW 50012, 'Attachment with this PublicId already exists.', 1;
        END;


        ----------------------------------------------------------------------
        -- Create Attachment
        --
        -- MessageId intentionally remains NULL.
        --
        -- The attachment is initially not associated with a message.
        -- SendMessage will associate it with the newly-created MessageId.
        ----------------------------------------------------------------------

        INSERT INTO chat.MessageAttachments
        (
            MessageId,
            PublicId,
            FileName,
            OriginalFileName,
            ContentType,
            FileExtension,
            FileSize,
            StoragePath,
            ThumbnailPath,
            DurationInSeconds,
            Width,
            Height,
            UploadedOn,
            UploadedByUserId
        )
        VALUES
        (
            NULL,
            @PublicId,
            @FileName,
            @OriginalFileName,
            @ContentType,
            @FileExtension,
            @FileSize,
            @StoragePath,
            @ThumbnailPath,
            @DurationInSeconds,
            @Width,
            @Height,
            SYSUTCDATETIME(),
            @UploadedByUserId
        );


        ----------------------------------------------------------------------
        -- Return Created Attachment
        ----------------------------------------------------------------------

        DECLARE @MessageAttachmentId BIGINT =
            SCOPE_IDENTITY();


        SELECT
            MA.MessageAttachmentId,
            MA.MessageId,
            MA.PublicId,
            MA.FileName,
            MA.OriginalFileName,
            MA.ContentType,
            MA.FileExtension,
            MA.FileSize,
            MA.StoragePath,
            MA.ThumbnailPath,
            MA.DurationInSeconds,
            MA.Width,
            MA.Height,
            MA.UploadedOn,
            MA.UploadedByUserId

        FROM chat.MessageAttachments MA

        WHERE MA.MessageAttachmentId = @MessageAttachmentId;

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH
END;
GO