USE MASTER

GO

-- המחשבה שלי הייתה להקים מערך דאטה על חנות בגדים לפי מספרי מוצר, סוגי פריטים, רשימת לקוחות, רשימת מוכרים, רשימת סםקים, מספרי סניפים וכו. תכף אפרט לגבי כל טבלה בנפרד.
IF EXISTS (SELECT * FROM SYSDATABASES WHERE NAME= 'Project_ZARA')
			DROP DATABASE Project_ZARA

GO

CREATE DATABASE Project_ZARA

GO

USE Project_ZARA

GO

--הקמתי טבלה ראשונה שאין לה מפתח משני על מנת שהטבלה תרוץ בצורה טובה. קודם כל מכניסים בנים ואז אבות. טבלת חנויות לפי מספרי סניפים עם אופציה שהטבלה תביא מספרים בצורה סדירה לפי מספר סניף, עיר - שלא תהיה ריקה ומדינה. בנוסף יש הודעת שגיאה על המפתח הראשי במידה ואצטרך אותה ואבין לאן לפנות. 
CREATE TABLE STORE
(BranchID INT IDENTITY CONSTRAINT STORE_ID_PK PRIMARY KEY,
City VARCHAR (20) NOT NULL,
Country Varchar (20)
)

GO

--הקמתי טבלה שניה שנוגעת לעובדים וקישרתי אותה ישירות דרך מפתח משני של מספר סניף למפתח הראשי מספר סניף של טבלת חנויות בהקשר של יחיד לרבים. המפתח הראשי של טבלה זו הוא מספר עובד. בנוסף יש הודעת שגיאה על המפתח הראשי במידה ואצטרך אותה ואבין לאן לפנות. בטבלה זו יש גם שם עובדים שלא יהיה ריק, משכורת עובד שלא תהיה ריקה ותאריך התחלת עבודה.
CREATE TABLE Employee
(EmployeeID INT CONSTRAINT EMPLOYEE_ID_PK PRIMARY KEY,
EmployeeName VARCHAR(25) NOT NULL,
EmployeeSalary MONEY NOT NULL,
StartDate DATE,
BranchID INT CONSTRAINT SHIP_ID_FK_2 FOREIGN KEY REFERENCES STORE(BranchID)
)

GO

--  בטבלה זו נמצאת טבלת לקוחות.ישנו מפתח ראשי של מספר לקוח. בנוסף יש הודעת שגיאה על המפתח הראשי במידה ואצטרך אותה ואבין לאן לפנות. בנוסף, גם בטבלה זו שם פרטי של לקוח ושם משפחה של לקוח ובשניהם חייב לכתוב משהו, אסור להשאיר את השדה ריק. בנוסף צריך להזין אימייל וזה לא חובה, אבל כאשר מזינים את זה לא נכון יש הודעת שגיאה שקופצת כי חייב לכתוב את המייל עם סימנים ברורים..
CREATE TABLE Customers
(CustomerID INT CONSTRAINT CUSTOMERS_ID_PK PRIMARY KEY,
FirstName VARCHAR (20) NOT NULL,
LastName VARCHAR (20) NOT NULL,
Email Varchar (30) CONSTRAINT CUSTOMER_EMAIL_CK CHECK (Email like '%@%.%')
)

GO

--בטבלה זו יצויין המשלוח. המפתח הראשי כאן הוא מספר משלוח. בנוסף יש הודעת שגיאה על המפתח הראשי במידה ואצטרך אותה ואבין לאן לפנות. בנוסף, יש כאן שם שליח מסוג ווארצ'ר שעליו יש הגבלה כי שם השליח צריך להיות ייחודי, יש גם תאריך הפצה של המשלוח ותאריך קבלה של המשלוח לידי הלקוח..  
CREATE TABLE SHIP
(ShipID INT CONSTRAINT SHIP_ID_PK PRIMARY KEY,
MessengerName VARCHAR (25) CONSTRAINT SHIP_NAME_UQ UNIQUE,
Delivery_Date_For_Distribution DATETIME,
Delivery_Receipt DATETIME
)

GO

--הטבלה הבאה היא טבלת הזמנות. מפתח ראשון הוא מספר ההזממנה. בנוסף יש עמודות של תאריך הזמנה ושל מספר יחידות במלאי. על עמודה זו יש הגבלה שמספר החידות במלאי חייבת להיות מעל 0. בנוסף, לטבלה זו יש 2 מפתחות משניים שמשוייכים לטבלאות הלקוחות ומשלוחים. כאשר הקשר הוא יחיד לרבים.
CREATE TABLE Orders
(OrderID INT CONSTRAINT ORDERS_ID_PK PRIMARY KEY,
OrderDATE DATE,
Quantity_In_Stock INT CONSTRAINT ORDERS_Quantity_CK CHECK (Quantity_In_Stock>=0),
CustomerID INT CONSTRAINT CUSTOMER_ID_FK FOREIGN KEY REFERENCES Customers(CustomerID),
SHIPID INT CONSTRAINT SHIP_ID_FK FOREIGN KEY REFERENCES SHIP(SHIPID)
)

GO


--בטבלה זו יש את טבלת הבגדים. מספר הבגד הוא המפתח הראשי, יש סוג הבגד שהוא חייב להיות ייחודי ולכ יש עליו הגבלה, מחיר הבגד, תאריך ייבוא הבגד, מספר המלאי שיש לבגד ומפתח משני של מספר הזמנה שמקושר ביחיד לרבים.
CREATE TABLE Clothes
(ClothesID INT CONSTRAINT CLOTHES_ID_PK PRIMARY KEY,
ClotheTYPE VARCHAR(15) CONSTRAINT CLOTHES_TYPE_UQ UNIQUE,
ClothesPRICE MONEY,
ImportDATE DATE,
Quantity_In_Stock INT,
OrderID INT CONSTRAINT ORDER_ID_FK FOREIGN KEY REFERENCES ORDERS(OrderID)
)

GO

--טבלה זו נוצרה על מנת לקשר בין שתי טבלאות שהקשר ביניהם קשר של רבים לרבים ולכן היא נוצרה. היא מקשרת בין טבלת בגדים לטבלת חנות משום שבגד אחד יכול להיות בהרבה חנויות וחנות אחת יכולה להכיל הרבה בגדים. כמובן שיש גם הוראת שגיאה על המפתחות הללו כדי שבמידה ותהיה שגיאה אדע לאן לפנות.
CREATE TABLE Store_Details
(ItemID INT IDENTITY CONSTRAINT STORE_DETAILS_ID_PK PRIMARY KEY,
ClothesID INT CONSTRAINT Clothe_ID_FK FOREIGN KEY REFERENCES Clothes(ClothesID),
BranchID INT CONSTRAINT STORE_ID_FK FOREIGN KEY REFERENCES STORE(BranchID)
)

GO

--טבלה זו היא טבלת ספקים. המפתח הראשי הוא מספר ספק. בנוסף יש פה שם הספק שחייב להיות ייחודי ותאריך ההספקה.
CREATE TABLE Supllier
(SupllierID INT CONSTRAINT SUPLLIER_ID_PK PRIMARY KEY,
SupllierName VARCHAR (25) CONSTRAINT SUPLLIER_NAME_UQ UNIQUE,
DateOfSupply DATE
)

GO

-- טבלה זו נוצרה על מנת להיות טבלה מקשרת בין 2 טבלאות שאמורות להיות מקושרות בין רבים לרבים, טבלת חנות וטבלת ספקים. לכל חנות אחת יש הרבה ספקים ובנוסף כל ספק אחד מספק להרבה חנויות.כמובן שיש גם הוראת שגיאה על המפתחות הללו כדי שבמידה ותהיה שגיאה אדע לאן לפנות.
CREATE TABLE Suply_Deatails
(NumberID INT IDENTITY CONSTRAINT SUPLY_DETAILS_ID_PK PRIMARY KEY,
BranchID INT CONSTRAINT SHIP_ID_FK_3 FOREIGN KEY REFERENCES STORE(BranchID),
SupllierID INT CONSTRAINT SUPLLIER_ID_FK FOREIGN KEY REFERENCES Supllier(SupllierID)
)

GO

INSERT INTO STORE
VALUES ('Haifa','Israel'),
		('Nahariya','Israel'),
		('Tel Aviv', 'Israel'),
		('Paris','France'),
		('Berlin','Germany'),
		('Budapest','Hungary'),
		('Eilat','Israel'),
		('Nice','France'),
		('Kan','France'),
		('Amsterdam','Holland'),
		('Hanoy','Vietnam'),
		('Athens','Greece'),
		('Rodos','Greece'),
		('Milano','Italy'),
		('Madrid','Spain'),
		('Barcelona','Spain'),
		('Rome','Italy'),
		('Hod Hasharon','Israel'),
		('Lima','Peru'),
		('Jerusalem','Israel'),
		('Tokyo','Japan'),
		('Rio De Janeiro','Brazil'),
		('Torino','Italy'),
		('Napoly','Italy'),
		('Verone','Italy'),
		('Lion','France'),
		('Normandi','France'),
		('Brazilia','Brazil'),
		('Sderot','Israel'),
		('Karmiel','Israel')

GO 

INSERT INTO Employee
VALUES (1,'Gal',9000,'2019-07-5',1),
		(2,'Bar',7500,'2022-08-14',2),
		(3,'Ofek',8800,'2020-05-23',3),
		(4,'Danit',12000,'2016-03-24',4),
		(5,'Dor',6500,'2018-12-30',5),
		(6,'Adva',18000,'2013-09-09',6),
		(7,'Galit',10000,'2019-05-30',7),
		(8,'Dror',11000,'2020-08-09',8),
		(9,'Shani',7500,'2019-12-20',9),
		(10,'Sharon',20000,'2017-11-11',10),
		(11,'Noam',6800,'2019-09-30',11),
		(12,'Hila',8800,'2020-06-25',12),
		(13,'Sohval',12000,'2016-03-24',13),
		(14,'Eden',7500,'2021-09-09',14),
		 (15,'Gali',9000,'2019-07-05',15),
		(16,'Gil',9000,'2018-08-09',16),
		(17,'Ben',15000,'2022-03-30',17),
		(18,'Sari',17000,'2017-09-12',18),
		(19,'Batya',18000,'2022-08-31',19),
		(20,'Mendy',8000,'2023-07-13',20),
		(21,'Menash',9500,'2021-04-16',20),
		(22,'Moses',10000,'2019-03-23',20),
		(23,'Nave',11000,'2018-08-27',21),
		(24,'Isar',15000,'2023-05-19',22),
		(25,'Irit',11500,'2022-12-31',23),
		(26,'Yarden',14000,'2021-06-20',24),
		(27,'Yuval',13500,'2017-09-16',25),
		(28,'Keren',11000,'2022-05-31',26),
		(29,'Vera',15000,'2024-05-11',27),
		(30,'Dor',19000,'2024-08-15',28),
		(31,'David',20000,'2015-07-28',29),
		(32,'Talya',17500,'2017-09-24',30),
		(33,'Beny',8700,'2024-10-12',8),
		(34,'Kaleb',9200,'2021-10-04',10),
		(35,'Yuri',5800,'2025-02-12',15)

GO

INSERT INTO Customers
VALUES (1000,'Edena','Levi','Edena@gmail.com'),
		(1001,'Shoam','Cohen','Shoam@gmail.com'),
		(1002,'Vered','Reger','VeredR@gmail.com'),
		(1003,'Mishell','Ben Simon','MishellBS@gmail.com'),
		(1004,'Nadav','Barel','Nadav@gmail.com'),
		(1005,'Iris','Sade','IrisS@gmail.com'),
		(1006,'Orel','Sason','Orel@gmail.com'),
		(1007,'Yosi','Levy','Yosi@gmail.com'),
		(1008,'Varda','Katz','Varde@gmail.com'),
		(1009,'Neta','Chen','NetaC@gmail.com'),
		(1010,'Shmuel','Hazan','Shmuel@gmail.com'),
		(1011,'Rotem','Regev','RotemR@gmail.com'),
		(1012,'Ran','Divovsky','RanD@gmail.com'),
		(1013,'Ron','Level','RonL@gmail.com'),
		(1014,'Dana','Volkov','DanaV@gmail.com'),
		(1015,'Patricia','Som','Patricia@gmail.com'),
		(1016,'Omri','Sela','OmriS@gmail.com'),
		(1017,'Bar','Buhbut','BarB@walla.com'),
		(1018,'Jenia','Levinsky','Jenia@walla.com'),
		(1019,'David','Nisanov','DavidN@yahoo.com'),
		(1020,'Dor','Bar','DorB@walla.com'),
		(1021,'Dany','Dor','DanyD@gmail.com'),
		(1022,'Edna','Katz','EdnaK@walla.com'),
		(1023,'Gal','Gilboa','GilGal@walla.com'),
		(1024,'Laora','Tirza','Laora@gmail.com'),
		(1025,'Yana','Levaiev','YanaL1@gmail.com'),
		(1026,'Natan','Kobi','NatanK@walla.com'),
		(1027,'Fadi','Faruk','FadiF@Yahoo.com'),
		(1028,'Kiril','Hecht','KirilH1@Yahoo.com'),
		(1029,'Evon','Simon','Evon@walla.com'),
		(1030,'Amor','Ben zikri','AmorBZ@walla.com')

GO

INSERT INTO Supllier
VALUES (10,'Smalot','2016-12-30'),
		(20,'Michnasaaim','2018-03-14'),
		(30,'Holtzot','2019-02-15'),
		(40,'Hatzayot','2018-06-20'),
		(50,'Gufiot','2020-07-08'),
		(60,'Naalaim','2022-03-30'),
		(70,'Sweder','2021-01-31'),
		(80,'kardigan','2024-05-23'),
		(90,'Taitz','2025-03-12'),
		(100,'Top','2019-06-24')

GO

INSERT INTO Suply_Deatails
VALUES (2,10),
		(4,20),
		(3,30),
		(1,40),
		(5,60),
		(6,50),
		(8,90),
		(9,100),
		(10,80),
		(11,80),
		(12,80),
		(13,40),
		(14,20),
		(15,50),
		(16,60),
		(17,80),
		(18,30),
		(19,20),
		(20,90),
		(21,40),
		(22,70),
		(23,10),
		(24,20),
		(25,70),
		(26,100),
		(27,100),
		(28,60),
		(29,50),
		(30,70)

GO

INSERT INTO SHIP
VALUES (2000,'Ben Levi',2023-07-27,2023-07-29),
		(2001,'Shalom Cohen',2020-02-14,2020-03-01),
		(2002,'Ruti Shoam',2018-06-06,2018-6-26),
		(2003,'Tal Gilboa',2019-05-13,2019-05-30),
		(2004,'Neta Omeri',2021-08-31,2022-09-05),
		(2005,'Victor Yelevich',2023-04-12,2023-04-20),
		(2006,'Viki Rozen','',''),
		(2007,'Ella Banay',2024-08-15,2024-09-01)

GO

INSERT INTO Orders
VALUES (12345,'2019-04-13',45,1001,2007),
		(12354,'2020-06-20',20,1005,2004),
		(23454,'2023-08-17',60,1003,2005),
		(66967,'2021-04-26',23,1002,2003),
		(13945,'2020-06-03',13,1011,2004),
		(11112,'2017-09-09',19,1015,2002),
		(34077,'2018-05-19',68,1016,2001),
		(17699,'2023-03-20',59,1017,2002),
		(14964,'2024-02-12',89,1020,2007),
		(15439,'2024-07-20',109,1030,2005),
		(12356,'2022-07-10',63,1029,2006),
		(19696,'2024-12-29',98,1004,2004),
		(18432,'2024-06-06',64,1006,2006),
		(24596,'2022-03-21',86,1010,2005),
		(19332,'2025-01-20',97,1012,2007),
		(12349,'2022-04-28',65,1014,2006),
		(16843,'2023-08-20',43,1013,2002),
		(15893,'2023-07-22',87,1018,2001),
		(19684,'2025-02-02',12,1019,2003),
		(29344,'2023-09-23',44,1021,2004),
		(12956,'2024-06-26',76,1022,2005),
		(18583,'2022-08-26',56,1023,2006),
		(12488,'2021-01-25',99,1025,2003),
		(18543,'2022-06-17',34,1027,2002),
		(17463,'2024-09-10',20,1028,2001),
		(19548,'2023-03-05',44,1029,2004),
		(14755,'2024-03-21',55,1024,2006),
		(19544,'2023-03-09',40,1020,2003),
		(18345,'2024-03-05',38,1022,2007),
		(17654,'2023-08-05',32,1010,2005),
		(14775,'2023-03-10',65,1008,2002),
		(19485,'2025-03-05',87,1004,2001)


GO

INSERT INTO Clothes
VALUES (1010,'Dress',200,'2019-05-31',39,14775),
		(1020,'bra',250,'2022-03-25',150,17654),
		(1030,'Shirt',150,'2021-02-23',400,12488),
		(1040,'Skirt',220,'2019-09-28',356,11112),
		(1050,'Jeans',300,'2018-01-31',186,66967),
		(1060,'Gloves',50,'2023-04-21',294,24596),
		(1070,'Socks',40,'2021-08-01',170,34077),
		(1080,'T-Shirt',100,'2019-03-24',500,14755),
		(1090,'Coat',550,'2020-12-20',132,19544),
		(1100,'Shoes',350,'2019-10-15',298,12345)

GO

INSERT INTO Store_Details
VALUES (1010,4),
		(1020,5),
		(1030,8),
		(1040,10),
		(1050,11),
		(1060,15),
		(1070,22),
		(1080,25),
		(1090,3),
		(1100,1),
		(1010,29),
		(1020,28),
		(1030,9),
		(1040,14),
		(1050,27),
		(1060,26),
		(1070,16),
		(1080,2),
		(1090,24),
		(1100,13)