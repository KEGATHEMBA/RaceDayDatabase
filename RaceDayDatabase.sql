USE master;
GO

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

CREATE TABLE Users
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20) NULL,
    Role NVARCHAR(20) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO

CREATE TABLE Events
(
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    EventDate DATETIME2 NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganiserId)
        REFERENCES Users(UserId),

    CONSTRAINT CK_Events_Distance
        CHECK (Distance > 0),

    CONSTRAINT CK_Events_Type
        CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);
GO

CREATE TABLE Categories
(
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryType NVARCHAR(20) NOT NULL,

    CONSTRAINT FK_Categories_Events
        FOREIGN KEY (EventId)
        REFERENCES Events(EventId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Categories_Type
        CHECK (CategoryType IN ('Age', 'Distance'))
);
GO

CREATE TABLE EventEnrolments
(
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantId)
        REFERENCES Users(UserId),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventId)
        REFERENCES Events(EventId),

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (CategoryId)
        REFERENCES Categories(CategoryId),

    CONSTRAINT UQ_Event_Participant
        UNIQUE (ParticipantId, EventId)
);
GO

CREATE TABLE Results
(
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL,
    FinishTime TIME NOT NULL,
    FinishingPosition INT NOT NULL,

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentId)
        REFERENCES EventEnrolments(EnrolmentId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Results_Position
        CHECK (FinishingPosition > 0)
);
GO

INSERT INTO Users
(FirstName, LastName, Email, PasswordHash, Phone, Role)
VALUES
(
    'Thabo',
    'Mokoena',
    'thabo@raceday.com',
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Password123'), 2),
    '0712345678',
    'Organiser'
),
(
    'Lerato',
    'Molefe',
    'lerato@raceday.com',
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Password123'), 2),
    '0723456789',
    'Organiser'
),
(
    'Kagiso',
    'Nkosi',
    'kagiso@raceday.com',
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Password123'), 2),
    '0734567890',
    'Participant'
),
(
    'Naledi',
    'Dlamini',
    'naledi@raceday.com',
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Password123'), 2),
    '0745678901',
    'Participant'
);
GO

INSERT INTO Events
(OrganiserId, Name, Description, EventDate, Location, Distance, EventType)
VALUES
(
    1,
    'Pretoria Spring Run',
    'Annual community running event.',
    '2026-10-10 08:00:00',
    'Pretoria',
    10.00,
    'Run'
),
(
    2,
    'Akasia Family Walk',
    'Family-friendly walking event.',
    '2026-11-07 09:00:00',
    'Akasia',
    5.00,
    'Walk'
),
(
    1,
    'Tshwane Cycle Challenge',
    'Cycling event for experienced and new riders.',
    '2026-12-05 07:00:00',
    'Tshwane',
    21.00,
    'Cycle'
);
GO

INSERT INTO Categories
(EventId, CategoryName, CategoryType)
VALUES
(1, 'Under 20', 'Age'),
(1, 'Senior', 'Age'),
(1, '10 km', 'Distance'),
(2, 'Under 20', 'Age'),
(2, 'Senior', 'Age'),
(2, '5 km', 'Distance'),
(3, 'Under 20', 'Age'),
(3, 'Senior', 'Age'),
(3, '21 km', 'Distance');
GO

INSERT INTO EventEnrolments
(ParticipantId, EventId, CategoryId)
VALUES
(3, 1, 3),
(4, 1, 3),
(3, 2, 6),
(4, 3, 9);
GO

INSERT INTO Results
(EnrolmentId, FinishTime, FinishingPosition)
VALUES
(1, '00:52:35', 1),
(2, '00:57:20', 2);
GO

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventEnrolments;
SELECT * FROM Results;
GO