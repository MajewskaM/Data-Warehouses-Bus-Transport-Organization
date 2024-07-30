USE BusTravel_DW
GO

INSERT INTO [dbo].[JUNK] (SatisfactionLevelCategory, OccupationCategory)
VALUES 
    ('none', 'very low'),
    ('none', 'low'),
    ('none', 'medium'),
    ('none', 'high'),
    ('low', 'very low'),
    ('low', 'low'),
    ('low', 'medium'),
    ('low', 'high'),
    ('medium', 'very low'),
    ('medium', 'low'),
    ('medium', 'medium'),
    ('medium', 'high'),
    ('high', 'very low'),
    ('high', 'low'),
    ('high', 'medium'),
    ('high', 'high');
