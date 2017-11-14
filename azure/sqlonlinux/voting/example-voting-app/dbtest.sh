sqlcmd -S localhost -U SA -P 'SuperSecretPassword1234'
-- SELECT Name from sys.Databases;
-- GO
USE Votes;
GO
SELECT COUNT(Vote) AS Total FROM Votes;
GO
SELECT Vote, COUNT(Vote) AS Votes FROM Votes GROUP BY Vote;
GO
QUIT
