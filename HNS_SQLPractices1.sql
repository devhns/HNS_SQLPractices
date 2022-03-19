-- Ýstanbul'da kaç müþteri var 
SELECT COUNT(*)
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
WHERE CT.CITY = 'ÝSTANBUL'

-- Tüm þehirlerde kaçar müþteri var
SELECT COUNT(*),CT.CITY
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY

-- Subquery ile tüm þehirlerde kaç müþteri var
SELECT *,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = CT.ID) AS CUSTCOUNT
FROM CITIES CT

-- 10'dan fazla müþteri olan þehirleri müþteri sayýsý ile beraber
-- müþteri sayýsýna göre çoktan aza sýralama
SELECT COUNT(*) AS CUSTCOUNT ,CT.CITY
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY
HAVING COUNT(CT.ID)>10
ORDER BY CUSTCOUNT ASC
-- Dikkat edilmesi gerekenler: Agreegate func. koþul vermek için having 
-- kullanýlýr. Having kullanýmý öncesinde group by olmak zorunda. 
-- order by sýralamada en sonu takip eder. Ayný zamanda aliaselar Group
-- by da kullanýlamaz, order by içinde kullanýlabilir.

-- Cinsiyete göre þehirlerin müþteri sayýlarýný bulma
SELECT CT.CITY,GENDER,COUNT(*) AS CUSTCOUNT
FROM CUSTOMERS CUS INNER JOIN CITIES CT
ON CT.ID = CUS.CITYID
GROUP BY CT.CITY,GENDER
ORDER BY CT.CITY ASC

-- Hangi þehirde kaç erkek kaç kadýn müþteri yaþýyor
SELECT ID,CITY AS SEHÝRADI,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID) AS MUSTERÝSAYÝSÝ,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID 
AND GENDER='E') AS ERKEKSAYÝSÝ,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID = C.ID 
AND GENDER='K') AS KADÝNSAYÝSÝ
FROM CITIES C

-- AGEGROUP alanýna müþteri kategorileme
SELECT * FROM CUSTOMERS
UPDATE CUSTOMERS SET AGEGROUP = '65 yaþ üstü'
WHERE DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65

-- Kodla sütun ekleme iþlemi
-- Alter table TabloAdi add SütunAdi Varchar(50) // D.tip, neyse en son o

SELECT AGEGROUP,count(*) as CUSTOMERCOUNT FROM CUSTOMERS
GROUP BY AGEGROUP

-- Age group sütununu kullanmadan farklý bi yolla hangi grupta kaç
-- müþteri mevcut saydýrma
SELECT 
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 üstü'
END AGEGROUP2,
COUNT(*) CUSTCOUNT
FROM CUSTOMERS
GROUP BY 
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 üstü'
END 
ORDER BY AGEGROUP2
-- AGEGROUP2 yine doðrudan GROUP BY içine olmadý o nedenle Aliase yerine 
-- kodu tekrar GB içine aktardýk.

-- Groupby içinde oluþturduðumuz bir Aliasý dinamik bir view aracýlýðýyla
-- kullanýp daha temiz bir kod yazabiliriz

SELECT AGEGROUP2,COUNT(TMP.ID) AS CUSTCOUNT FROM 
(SELECT *,
CASE
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 20 AND 35 THEN '20-35'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 55 AND 65 THEN '55-65'
	WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE())>65 THEN '65 üstü'
END AGEGROUP2 FROM CUSTOMERS) TMP
GROUP BY AGEGROUP2
-- Burada sanki TMP adýnda bir table varmýþ gibi bir yapý hazýrladýk
-- ve bu table'a ait AGEGROUP2 column da kodu uzunca yazmadan kullanýp sayým saðladýk

-- Ýstanbulda yaþayýp ilçesi Kadýköy dýþýnda olan müþteriler
SELECT *,DISTRICT FROM CUSTOMERS CUS JOIN 
DISTRICT DIS ON CUS.DISTRICTID = DIS.ID
WHERE DIS.DISTRICT !=  'KADIKÖY'

-- Eðer tablodan delete ile sildiðimiz verileri eksik IDlere geri koymak istersek
-- bunun için anlýk olarak Identity Specified i tum tablo adýna kaldýrmak çok yanlýþ
-- sonuclar doðurabilir. O nedenle bunu yalnýzca anlýk olarak açmak için
-- SET IDENTITY_INSERT TABLO ON komutunu eklemek istediðimiz blokla beraber çalýþtýrýrýz.

-- EXMP: SET IDENTITY_INSERT TABLO ON 
--		 INSERT INTO CITIES (ID,CITY) VALUES(6,'ANKARA')

--Operator numaralarýný çekme
SELECT *, LEFT(TELNR1,5) AS OPERATOR1,LEFT(TELNR2,5) AS OPERATOR2  FROM CUSTOMERS 

--2.yol substring / ara kýsýtlama saðladýðý için  iç kýsýmlardaki aramalarda da 
--daha çok kolaylýk saðlamýþ olur
SELECT *, SUBSTRING(TELNR1,1,5) AS OPERATOR1,
SUBSTRING(TELNR2,1,5) AS OPERATOR2  FROM CUSTOMERS 

-- Numarasý 50 ya da 55 ile baþlayan X, 54 ile baþlayan Y, 53 ile baþlayan Z operatorü
-- Hangi operatörden kaç müþteri var bilgisi 

--M SOLV (nulleride içeren ve satýr bazýnda sonuc veren)
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

-- Her ilde en çok müþteri olan ilçeleri çoktan aza doðru sýralama
SELECT CT.CITY,DIS.DISTRICT,COUNT(CT.ID) AS CUSTOMERCOUNT FROM CUSTOMERS CUS 
INNER JOIN CITIES CT ON CT.ID = CUS.CITYID
INNER JOIN DISTRICT DIS ON CUS.DISTRICTID = DIS.ID 
GROUP BY CT.CITY,DIS.DISTRICT
ORDER BY CT.CITY,COUNT(CT.ID) DESC
-- Diðer yazým þekli olarak sütun num. kullanabiliriz.
-- ORDER BY 1,3 DESC

-- ** Bilgi: Eðer bir sütun burda eþlediðimiz tablolardan yalnýzca birindeyse
-- sistem sütunu adýyla algýlayabilir yani aliase kullanmadan CT.CITY yerine CITY desem
-- de bana çýktý verirdi. Ama ID dersem her tablonun ID bilgisi var ve kendine öz.
-- Ne þekilde kullanacaðýný bilemediðinden ambiguous (belirsizlik) hatasý verir.

-- Müþterilerin doðum günleri ayýn hangi gününe denk geliyor (DATENAME FONKSÝYONSUZ)
SELECT BIRTHDATE AS TARÝH,
DATEPART(DW,BIRTHDATE) AS AYINGUNU,
DATEPART(DW,BIRTHDATE) AS HAFTANINGUNU,

CASE 
	WHEN DATEPART(DW,BIRTHDATE) = 1 THEN 'Pazartesi' 
	WHEN DATEPART(DW,BIRTHDATE) = 2 THEN 'Salý' 
	WHEN DATEPART(DW,BIRTHDATE) = 3 THEN 'Çarþamba' 
	WHEN DATEPART(DW,BIRTHDATE) = 4 THEN 'Perþembe' 
	WHEN DATEPART(DW,BIRTHDATE) = 5 THEN 'Cuma' 
	WHEN DATEPART(DW,BIRTHDATE) = 6 THEN 'Cumartesi' 
	WHEN DATEPART(DW,BIRTHDATE) = 7 THEN 'Pazar' 
	END GUNADI

FROM CUSTOMERS

-- DATENAME kullanarak
SET LANGUAGE English
SELECT DATENAME(DW,BIRTHDATE) AS Günler,BIRTHDATE FROM CUSTOMERS 
-- Gün isimlerinin Türkçe olmasý için SEC - Logins - Kullanýcý - Default Lang TR yapýlýrsa
-- kod çalýþtýktan sonra gerekli çýktý alýnýr. Yoksa default EN þeklinde geliyor günler.
-- Ama bu tüm sistemi etkiler, illa kullanýcý dilinde deðiþiklik yapmaya gerek yok. 
-- Biz sýrf o kod çalýþýnca böyle bir sonuç almak istiyorsak
-- SET Language DÝL þeklinde giriþ yaparak halledebiliriz.


-- Bugünün tarihi (ÖRN:bu blok için 19.03)'te doðanlarý bulalým
SELECT * FROM CUSTOMERS
WHERE DATEPART(MONTH,BIRTHDATE) = DATEPART(MONTH,GETDATE()) AND
DATEPART(DAY,BIRTHDATE) = DATEPART(DAY,GETDATE())
-- 2.W: Datepart yerine Gün,Ay için direkt MONTH() VE DAY() de kullanabiliriz.

-- Notes from HNS. 
-- UpL.Date: 19/03/2022 
-- Source: Ömer Çolakoðlu - 'Alýþtýrmalarla SQL'