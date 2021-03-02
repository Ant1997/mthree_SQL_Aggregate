use PersonalTrainer;

-- Use an aggregate to count the number of Clients.
-- 500 rows
SELECT COUNT(*)
FROM Client; 

--------------------

-- Use an aggregate to count Client.BirthDate.
-- The number is different than total Clients. Why?
-- 463 rows
SELECT COUNT(Client.BirthDate)
FROM Client; 

SELECT *
FROM Client; 
-- The number is different than total Client because some clients do not have birthdate entered in the database. 
--------------------

-- Group Clients by City and count them.
-- Order by the number of Clients desc.
-- 20 rows
SELECT COUNT(*) as City
FROM Client
GROUP BY Client.City
ORDER BY COUNT(*); 

--------------------

-- Calculate a total per invoice using only the InvoiceLineItem table.
-- Group by InvoiceId.
-- You'll need an expression for the line item total: Price * Quantity.
-- Aggregate per group using SUM().
-- 1000 rows

SELECT InvoiceId, SUM(Price * Quantity) as Total
FROM InvoiceLineItem
GROUP BY InvoiceId;
--------------------

-- Calculate a total per invoice using only the InvoiceLineItem table.
-- (See above.)
-- Only include totals greater than $500.00.
-- Order from lowest total to highest.
-- 234 rows

SELECT InvoiceId, SUM(Price * Quantity) as Total
FROM InvoiceLineItem
GROUP BY InvoiceId
HAVING SUM(Price * Quantity) > 500
ORDER BY SUM(Price * Quantity) Asc; 

--------------------

-- Calculate the average line item total
-- grouped by InvoiceLineItem.Description.
-- 3 rows

SELECT InvoiceId, AVG(Price * Quantity) as Total, Description
FROM InvoiceLineItem
GROUP BY InvoiceLineItem.Description;
--------------------

-- Select ClientId, FirstName, and LastName from Client
-- for clients who have *paid* over $1000 total.
-- Paid is Invoice.InvoiceStatus = 2.
-- Order by LastName, then FirstName.
-- 146 rows

SELECT Client.ClientId, Client.FirstName, Client.LastName
FROM Client
INNER JOIN Invoice ON Invoice.ClientId = Client.ClientId
INNER JOIN InvoiceLineItem ON InvoiceLineItem.InvoiceId = Invoice.InvoiceId
WHERE Invoice.InvoiceStatus = 2 
GROUP BY ClientId, FirstName, LastName
HAVING SUM(InvoiceLineItem.Price * InvoiceLineItem.Quantity) > 1000.00
ORDER BY Client.LastName, Client.FirstName; 

--------------------

-- Count exercises by category.
-- Group by ExerciseCategory.Name.
-- Order by exercise count descending.
-- 13 rows

SELECT ExerciseCategory.Name, COUNT(ExerciseCategory.ExerciseCategoryId) as TotalExercises
FROM ExerciseCategory
INNER JOIN Exercise ON ExerciseCategory.ExerciseCategoryId = Exercise.ExerciseCategoryId
GROUP BY ExerciseCategory.ExerciseCategoryId
ORDER BY COUNT(ExerciseCategory.Name) Desc;
--------------------

-- Select Exercise.Name along with the minimum, maximum,
-- and average ExerciseInstance.Sets.
-- Order by Exercise.Name.
-- 64 rows

SELECT Exercise.Name,
	MIN(ExerciseInstance.Sets),
	MAX(ExerciseInstance.Sets),
    AVG(ExerciseInstance.Sets)
FROM Exercise
JOIN ExerciseInstance ON ExerciseInstance.ExerciseId = Exercise.ExerciseId
GROUP BY Exercise.ExerciseId, Exercise.Name
ORDER BY Exercise.Name;

--------------------

-- Find the minimum and maximum Client.BirthDate
-- per Workout.
-- 26 rows
-- Sample: 
-- WorkoutName, EarliestBirthDate, LatestBirthDate
-- '3, 2, 1... Yoga!', '1928-04-28', '1993-02-07'

SELECT Workout.Name, MIN(Client.BirthDate), MAX(Client.BirthDate)
FROM Client
JOIN ClientWorkout ON ClientWorkout.ClientId = Client.ClientId
JOIN Workout ON Workout.WorkoutId = ClientWorkout.WorkoutId
GROUP BY Workout.Name; 
--------------------

-- Count client goals.
-- Be careful not to exclude rows for clients without goals.
-- 500 rows total
-- 50 rows with no goals

SELECT Client.FirstName, Client.LastName, COUNT(Goal.GoalId) 
FROM Client
LEFT OUTER JOIN ClientGoal ON Client.ClientId = ClientGoal.ClientId
LEFT OUTER JOIN Goal ON ClientGoal.GoalId = Goal.GoalId
GROUP BY Client.ClientId;

--------------------

-- Select Exercise.Name, Unit.Name, 
-- and minimum and maximum ExerciseInstanceUnitValue.Value
-- for all exercises with a configured ExerciseInstanceUnitValue.
-- Order by Exercise.Name, then Unit.Name.
-- 82 rows
SELECT
	e.`Name` ExerciseName,
    u.`Name` UnitName,
    MIN(uv.Value) MinValue,
    MAX(uv.Value) 'MaxValue'
FROM Exercise e
INNER JOIN ExerciseInstance ei 
	ON e.ExerciseId = ei.ExerciseId
INNER JOIN ExerciseInstanceUnitValue uv 
	ON ei.ExerciseInstanceId = uv.ExerciseInstanceId
INNER JOIN Unit u ON uv.UnitId = u.UnitId
GROUP BY e.ExerciseId, e.`Name`, u.UnitId, u.`Name`
ORDER BY e.`Name`, u.`Name`;
--------------------

-- Modify the query above to include ExerciseCategory.Name.
-- Order by ExerciseCategory.Name, then Exercise.Name, then Unit.Name.
-- 82 rows
SELECT
	c.`Name` CategoryName,
	e.`Name` ExerciseName,
    u.`Name` UnitName,
    MIN(uv.Value) MinValue,
    MAX(uv.Value) 'MaxValue'
FROM Exercise e
INNER JOIN ExerciseInstance ei 
	ON e.ExerciseId = ei.ExerciseId
INNER JOIN ExerciseInstanceUnitValue uv 
	ON ei.ExerciseInstanceId = uv.ExerciseInstanceId
INNER JOIN Unit u 
	ON uv.UnitId = u.UnitId
INNER JOIN ExerciseCategory c 
	ON e.ExerciseCategoryId = c.ExerciseCategoryId
GROUP BY e.ExerciseId, e.`Name`, u.UnitId, u.`Name`, c.`Name`
ORDER BY c.`Name`, e.`Name`, u.`Name`;

--------------------

-- Select the minimum and maximum age in years for
-- each Level.
-- To calculate age in years, use the MySQL function DATEDIFF.
-- 4 rows
SELECT
	Level.Name,
	MIN(DATEDIFF(CURDATE(), Client.BirthDate) / 365) as MinAge,
    MAX(DATEDIFF(CURDATE(), Client.BirthDate) / 365) as MaxAge
FROM Level 
INNER JOIN Workout ON Level.LevelId = Workout.LevelId
INNER JOIN ClientWorkout ON Workout.WorkoutId = ClientWorkout.WorkoutId
INNER JOIN Client ON ClientWorkout.ClientId = Client.ClientId
GROUP BY Level.LevelId, Level.Name;

--------------------

-- Stretch Goal!
-- Count logins by email extension (.com, .net, .org, etc...).
-- Research SQL functions to isolate a very specific part of a string value.
-- 27 rows (27 unique email extensions)
SELECT
	SUBSTRING_INDEX(EmailAddress, '.', -1),
    COUNT(EmailAddress)
FROM Login
GROUP BY SUBSTRING_INDEX(EmailAddress, '.', -1)
ORDER BY COUNT(EmailAddress) DESC;

--------------------

-- Stretch Goal!
-- Match client goals to workout goals.
-- Select Client FirstName and LastName and Workout.Name for
-- all workouts that match at least 2 of a client's goals.
-- Order by the client's last name, then first name.
-- 139 rows

SELECT Client.FirstName, Client.LastName, Workout.Name, COUNT(ClientGoal.GoalId)
FROM Client
JOIN ClientGoal ON ClientGoal.ClientId = Client.ClientId
JOIN WorkoutGoal ON WorkoutGoal.GoalId = ClientGoal.GoalId
JOIN Workout ON WorkoutGoal.WorkoutId = Workout.WorkoutId
GROUP BY Workout.WorkoutId, Workout.Name, Client.ClientId, Client.FirstName, Client.LastName
HAVING COUNT(ClientGoal.GoalId) > 1
ORDER BY Client.FirstName, Client.LastName;
--------------------
