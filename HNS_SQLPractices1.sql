-- �stanbul'da ka� m��teri var 
SELECT COUNT(*)
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
WHERE CT.CITY = '�STANBUL'

-- T�m �ehirlerde ka�ar m��teri var
SELECT COUNT(*),CT.CITY
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY

-- Subquery ile t�m �ehirlerde ka� m��teri var
SELECT *,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = CT.ID) AS CUSTCOUNT
FROM CITIES CT

-- 10'dan fazla m��teri olan �ehirleri m��teri say�s� ile beraber
-- m��teri say�s�na g�re �oktan aza s�ralama
SELECT COUNT(*) AS CUSTCOUNT ,CT.CITY
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY
HAVING COUNT(CT.ID)>10
ORDER BY CUSTCOUNT ASC
-- Dikkat edilmesi gerekenler: Agreegate func. ko�ul vermek i�in having 
-- kullan�l�r. Having kullan�m� �ncesinde group by olmak zorunda. 
-- order by s�ralamada en sonu takip eder. Ayn� zamanda aliaselar Group
-- by da kullan�lamaz, order by i�inde kullan�labilir.

-- Cinsiyete g�re �ehirlerin m��teri say�lar�n� bulma
SELECT CT.CITY,GENDER,COUNT(*) AS CUSTCOUNT
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY,GENDER
ORDER BY CT.CITY ASC

-- Hangi �ehirde ka� erkek ka� kad�n m��teri ya��yor
SELECT ID,CITY AS SEH�RADI,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID) AS MUSTER�SAY�S�,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID 
AND GENDER='E') AS ERKEKSAY�S�,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID 
AND GENDER='K') AS KAD�NSAY�S�
FROM CITIES C

-- AGEGROUP alan�na m��teri kategorileme
SELECT * FROM CUSTOMERS
UPDATE CUSTOMERS SET AGEGROUP = '65 ya� �st�'
WHERE DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65

-- Kodla s�tun ekleme i�lemi
-- Alter table TabloAdi add S�tunAdi Varchar(50) // D.tip, neyse en son o

SELECT AGEGROUP,count(*) as CUSTOMERCOUNT FROM CUSTOMERS
GROUP BY AGEGROUP

-- Age group s�tununu kullanmadan farkl� bi yolla hangi grupta ka�
-- m��teri mevcut sayd�rma
SELECT 
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 �st�'
END AGEGROUP2,
COUNT(*) CUSTCOUNT
FROM CUSTOMERS
GROUP BY 
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 �st�'
END 
ORDER BY AGEGROUP2
-- AGEGROUP2 yine do�rudan GROUP BY i�ine olmad� o nedenle Aliase yerine 
-- kodu tekrar GB i�ine aktard�k.

-- Groupby i�inde olu�turdu�umuz bir Alias� dinamik bir view arac�l���yla
-- kullan�p daha temiz bir kod yazabiliriz

SELECT AGEGROUP2,COUNT(TMP.ID) AS CUSTCOUNT FROM 
(SELECT *,
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 �st�'
END AGEGROUP2 FROM CUSTOMERS) TMP
GROUP BY AGEGROUP2
-- Burada sanki TMP ad�nda bir table varm�� gibi bir yap� haz�rlad�k
-- ve bu table'a ait AGEGROUP2 column da kodu uzunca yazmadan kullan�p say�m sa�lad�k

-- �stanbulda ya�ay�p il�esi Kad�k�y d���nda olan m��teriler
SELECT *,DISTRICT FROM CUSTOMERS CUS JOIN 
DISTRICT DIS ON CUS.DISTRICTID = DIS.ID
WHERE DIS.DISTRICT !=  'KADIK�Y'

-- E�er tablodan delete ile sildi�imiz verileri eksik IDlere geri koymak istersek
-- bunun i�in anl�k olarak Identity Specified i tum tablo ad�na kald�rmak �ok yanl��
-- sonuclar do�urabilir. O nedenle bunu yaln�zca anl�k olarak a�mak i�in
-- SET IDENTITY_INSERT TABLO ON komutunu eklemek istedi�imiz blokla beraber �al��t�r�r�z.

-- EXMP: SET IDENTITY_INSERT TABLO ON 
--		 INSERT INTO CITIES (ID,CITY) VALUES(6,'ANKARA')

--Operator numaralar�n� �ekme
SELECT *, LEFT(TELNR1,5) AS OPERATOR1,LEFT(TELNR2,5) AS OPERATOR2  FROM CUSTOMERS 

--2.yol substring / ara k�s�tlama sa�lad��� i�in  i� k�s�mlardaki aramalarda da 
--daha �ok kolayl�k sa�lam�� olur
SELECT *, SUBSTRING(TELNR1,1,5) AS OPERATOR1,
SUBSTRING(TELNR2,1,5) AS OPERATOR2  FROM CUSTOMERS 

-- Numaras� 50 ya da 55 ile ba�layan X, 54 ile ba�layan Y, 53 ile ba�layan Z operator�
-- Hangi operat�rden ka� m��teri var bilgisi 

--M SOLV (nulleride i�eren ve sat�r baz�nda sonuc veren)
SELECT OPERATORLER,COUNT(OP.ID) AS CUSTCOUNT FROM 
(SELECT *, 
CASE 
	WHEN SUBSTRING(TELNR1,2,2) = 50 OR SUBSTRING(TELNR1,2,2) = 50 THEN 'XOPERATOR'
	WHEN SUBSTRING(TELNR2,2,2) = 50 OR SUBSTRING(TELNR2,2,2) = 50 THEN 'XOPERATOR'
	WHEN SUBSTRING(TELNR1,2,2) = 54 THEN 'YOPERATOR'
	WHEN SUBSTRING(TELNR2,2,2) = 54 THEN 'YOPERATOR'
	WHEN SUBSTRING(TELNR1,2,2) = 53 THEN 'ZOPERATOR'
	WHEN SUBSTRING(TELNR2,2,2) = 53 THEN 'ZOPERATOR'
END OPERATORLER FROM CUSTOMERS) OP 
GROUP BY OPERATORLER ORDER BY OPERATORLER ASC

-- Her ilde en �ok m��teri olan il�eleri �oktan aza do�ru s�ralama
SELECT CT.CITY,DIS.DISTRICT,COUNT(CT.ID) AS CUSTOMERCOUNT FROM CUSTOMERS CUS 
INNER JOIN CITIES CT ON CT.ID = CUS.CITYID
INNER JOIN DISTRICT DIS ON CUS.DISTRICTID = DIS.ID 
GROUP BY CT.CITY,DIS.DISTRICT
ORDER BY CT.CITY,COUNT(CT.ID) DESC
-- Di�er yaz�m �ekli olarak s�tun num. kullanabiliriz.
-- ORDER BY 1,3 DESC

-- ** Bilgi: E�er bir s�tun burda e�ledi�imiz tablolardan yaln�zca birindeyse
-- sistem s�tunu ad�yla alg�layabilir yani aliase kullanmadan CT.CITY yerine CITY desem
-- de bana ��kt� verirdi. Ama ID dersem her tablonun ID bilgisi var ve kendine �z.
-- Ne �ekilde kullanaca��n� bilemedi�inden ambiguous (belirsizlik) hatas� verir.

-- M��terilerin do�um g�nleri ay�n hangi g�n�ne denk geliyor (DATENAME FONKS�YONSUZ)
SELECT BIRTHDATE AS TAR�H,
DATEPART(DW,BIRTHDATE) AS AYINGUNU,
DATEPART(DW,BIRTHDATE) AS HAFTANINGUNU,

CASE 
	WHEN DATEPART(DW,BIRTHDATE) = 1 THEN 'Pazartesi' 
	WHEN DATEPART(DW,BIRTHDATE) = 2 THEN 'Sal�' 
	WHEN DATEPART(DW,BIRTHDATE) = 3 THEN '�ar�amba' 
	WHEN DATEPART(DW,BIRTHDATE) = 4 THEN 'Per�embe' 
	WHEN DATEPART(DW,BIRTHDATE) = 5 THEN 'Cuma' 
	WHEN DATEPART(DW,BIRTHDATE) = 6 THEN 'Cumartesi' 
	WHEN DATEPART(DW,BIRTHDATE) = 7 THEN 'Pazar' 
	END GUNADI

FROM CUSTOMERS

-- DATENAME kullanarak
SET LANGUAGE English
SELECT DATENAME(DW,BIRTHDATE) AS G�nler,BIRTHDATE FROM CUSTOMERS 
-- G�n isimlerinin T�rk�e olmas� i�in SEC - Logins - Kullan�c� - Default Lang TR yap�l�rsa
-- kod �al��t�ktan sonra gerekli ��kt� al�n�r. Yoksa default EN �eklinde geliyor g�nler.
-- Ama bu t�m sistemi etkiler, illa kullan�c� dilinde de�i�iklik yapmaya gerek yok. 
-- Biz s�rf o kod �al���nca b�yle bir sonu� almak istiyorsak
-- SET Language D�L �eklinde giri� yaparak halledebiliriz.


-- Bug�n�n tarihi (�RN:bu blok i�in 19.03)'te do�anlar� bulal�m
SELECT * FROM CUSTOMERS
WHERE DATEPART(MONTH,BIRTHDATE) = DATEPART(MONTH,GETDATE()) AND
DATEPART(DAY,BIRTHDATE) = DATEPART(DAY,GETDATE())
-- 2.W: Datepart yerine G�n,Ay i�in direkt MONTH() VE DAY() de kullanabiliriz.

-- Notes from HNS. 
-- UpL.Date: 19/03/2022 
-- Source: �mer �olako�lu - 'Al��t�rmalarla SQL'