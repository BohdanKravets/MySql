
-- 1. +Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.
SELECT * FROM client WHERE LENGTH(FirstName) < 6;

-- 2. +Вибрати львівські відділення банку.+
SELECT * FROM department WHERE DepartmentCity = 'Lviv';

-- 3. +Вибрати клієнтів з вищою освітою та посортувати по прізвищу.
SELECT * FROM client where Education = 'high' ORDER BY LastName;

-- 4. +Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.
SELECT * FROM application ORDER BY idApplication DESC LIMIT 5;

-- 5. +Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.
SELECT * FROM client WHERE LastName LIKE '%OV' OR '%OVA';

-- 6. +Вивести клієнтів банку, які обслуговуються київськими відділеннями.
SELECT * FROM client WHERE Department_idDepartment IN
(SELECT idDepartment FROM department WHERE DepartmentCity ='Kyiv');

-- 7. +Вивести імена клієнтів та їхній паспорт, посортувати їх за іменами.
SELECT FirstName,Passport FROM client ORDER BY FirstName;

-- 8. +Вивести дані про клієнтів, які мають кредит більше ніж на 5000 тисяч гривень.
SELECT * FROM client c JOIN application a ON c.idClient = a.Client_idClient
WHERE a.Sum > 5000 AND a.CreditState = ' Not returned';

-- 9. +Порахувати кількість клієнтів усіх відділень та лише львівських відділень.
SELECT COUNT(*) FROM client;
SELECT COUNT(*) AS lvivDepClientsNum FROM client c
JOIN department d ON c.Department_idDepartment = d.idDepartment
WHERE d.DepartmentCity = 'Lviv';

-- 10. Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.
SELECT c.idClient, c.FirstName, c.LastName, MAX(a.Sum) as maxCreditSum
FROM client c JOIN application a ON c.idClient = a.Client_idClient GROUP BY c.idClient;

-- 11. Визначити кількість заявок на крдеит для кожного клієнта.
SELECT c.idClient, c.FirstName, c.LastName, COUNT(a.Client_idClient) as clientAppCount
FROM client c JOIN application a ON c.idClient = a.Client_idClient GROUP BY c.idClient;

--
-- 12. Визначити найбільший та найменший кредити.
SELECT * FROM application WHERE Sum IN (SELECT MAX(Sum) FROM application);

SELECT * FROM application WHERE Sum IN (SELECT MIN(Sum) FROM application);

-- 13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.
SELECT COUNT(*) FROM application a JOIN client c ON a.Client_idClient = c.idClient WHERE c.Education = 'high';

-- 14. Вивести дані про клієнта, в якого середня сума кредитів найвища.
SELECT c.idClient, c.FirstName, c.LastName, AVG(a.SUM) as avgCreditSum
FROM client c JOIN application a ON c.idClient = a.Client_idClient
GROUP BY c.idClient ORDER BY avgCreditSum DESC LIMIT 1;


-- 15. Вивести відділення, яке видало в кредити найбільше грошей
SELECT d.idDepartment,d.DepartmentCity,d.CountOfWorkers, SUM(a.Sum) as depCreditSum
FROM department d JOIN client c ON d.idDepartment = c.Department_idDepartment
JOIN  application a ON c.idClient = a.Client_idClient
GROUP BY d.idDepartment ORDER BY depCreditSum DESC LIMIT 1;

-- 16. Вивести відділення, яке видало найбільший кредит.
SELECT d.idDepartment,d.DepartmentCity,d.CountOfWorkers, MAX(a.Sum) as maxDepCreditSum
FROM department d JOIN client c ON d.idDepartment = c.Department_idDepartment
JOIN  application a ON c.idClient = a.Client_idClient
GROUP BY d.idDepartment ORDER BY maxDepCreditSum DESC LIMIT 1;
--
-- 17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.
UPDATE application SET Sum = 6000,Currency = 'Gryvnia' WHERE Client_idClient IN
(SELECT idClient FROM client  WHERE Education = 'high' );

-- 18. Усіх клієнтів київських відділень пересилити до Києва.
UPDATE client SET City = 'Kyiv' WHERE Department_idDepartment IN
(SELECT idDepartment FROM department WHERE DepartmentCity = 'Kyiv');
--
-- 19. Видалити усі кредити, які є повернені.
DELETE FROM application WHERE CreditState = 'Returned';
--
--
-- 20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.
DELETE FROM application WHERE Client_idClient IN
(SELECT idClient FROM client WHERE
       LastName LIKE '_o%' OR LastName LIKE '_a%' OR
       LastName LIKE '_e%' OR LastName LIKE '_y%' OR
       LastName LIKE '_u%' OR LastName LIKE '_i%');

-- Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000
SELECT d.idDepartment,d.DepartmentCity,d.CountOfWorkers, SUM(a.Sum) as depCreditSum
FROM department d JOIN client c ON d.idDepartment = c.Department_idDepartment
JOIN  application a ON c.idClient = a.Client_idClient
GROUP BY d.idDepartment HAVING depCreditSum >5000 AND d.DepartmentCity = 'Lviv';

-- Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000
SELECT c.idClient, c.FirstName, c.LastName,SUM(a.Sum) as returnedCreditSum
FROM client c JOIN application a ON c.idClient = a.Client_idClient  WHERE a.CreditState = 'Returned'
GROUP BY c.idClient HAVING returnedCreditSum > 5000 ;

--
-- /* Знайти максимальний неповернений кредит.*/
SELECT * FROM application WHERE CreditState = 'Not returned' ORDER BY Sum DESC LIMIT 1;

-- /*Знайти клієнта, сума кредиту якого найменша*/
SELECT idClient,FirstName,LastName FROM client
WHERE idClient IN (SELECT Client_idClient FROM application
WHERE Sum IN (SELECT MIN(Sum) FROM application));

-- /*Знайти кредити, сума яких більша за середнє значення усіх кредитів*/
SELECT * FROM application WHERE Sum > (SELECT AVG(SUM) FROM application);


-- /*Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів*/
SELECT * FROM client WHERE City = (
    SELECT c.City FROM client c JOIN application a ON c.idClient = a.Client_idClient
    GROUP BY a.Client_idClient ORDER BY COUNT(a.Client_idClient) DESC LIMIT 1);


-- #місто чувака який набрав найбільше кредитів
SELECT c.City FROM client c JOIN application a ON  c.idClient = a.Client_idClient
GROUP BY a.Client_idClient ORDER BY COUNT(a.Client_idClient) DESC LIMIT 1;