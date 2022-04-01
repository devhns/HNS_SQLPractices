-- Sirkette hala çalismaya devam eden çalisanlar
SELECT * FROM PERSON  WHERE OUTDATE IS NULL 

-- Departman bazinda çalismaya devam eden kadin erkek sayilari (Satir bazli)
SELECT DEPARTMENT,
CASE
	WHEN PER.GENDER = 'E' THEN 'Erkek'
	WHEN PER.GENDER = 'K' THEN 'Kadýn'
END GENDER,
COUNT(*) AS PERSONCOUNT FROM 
PERSON PER INNER JOIN DEPARTMENT DEP 
ON PER.DEPARTMENTID = DEP.ID 
WHERE PER.OUTDATE IS NULL 
GROUP BY DEP.DEPARTMENT,GENDER
ORDER BY DEP.DEPARTMENT ASC

-- Departman bazinda çaliþmaya devam eden kadin erkek sayilarý (Sutun bazli)
-- Sutun bazinda atama isleminde subquery kullanarak alias veriyoruz
-- ve ciktida istenen sonucu yeni bir sutun olarak gorebiliyoruz 
SELECT *,
(SELECT  COUNT(*) FROM PERSON WHERE DEPARTMENTID = DEP.ID AND 
GENDER = 'E' AND OUTDATE IS NULL) AS ERKEK_CALISAN,
(SELECT  COUNT(*) FROM PERSON WHERE DEPARTMENTID = DEP.ID AND 
GENDER = 'K' AND OUTDATE IS NULL) AS KADIN_CALISAN
FROM DEPARTMENT DEP
ORDER BY DEP.DEPARTMENT ASC

-- Sirketin  planlama bölümüne atanacak yeni bir sef için minimum,maximum
-- ve ortalama maas degerleri 

SELECT POSITION, MIN(SALARY) AS MINIMUM, MAX(SALARY) AS MAXIMUM,
ROUND(AVG(SALARY),0) AS AVERAGE FROM PERSON PER INNER JOIN POSITION POS
ON PER.POSITIONID = POS.ID  WHERE POSITIONID = 25
GROUP BY POS.POSITION

-- Pozisyon bazinda mevcut çalýsan sayisi ve ortalama maasin listelenmesi
SELECT P.POSITION, COUNT(*) AS PER_COUNT,
ROUND(AVG(SALARY),0) AS AVG_SAL FROM PERSON PER INNER JOIN POSITION P
ON PER.POSITIONID = P.ID 
WHERE OUTDATE IS NULL
GROUP BY P.POSITION

--Yillara göre ise alinan personel sayisinin kadin ve erkek bazinda listelenmesi
SELECT DISTINCT(YEAR(INDATE)) AS YILLAR,
(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'E' AND YEAR(INDATE)=YEAR(PER.INDATE)) AS ERKEK_C,
(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'K' AND YEAR(INDATE)=YEAR(PER.INDATE)) AS KADIN_C
FROM PERSON PER
ORDER BY YEAR(INDATE) ASC

-- Her bir personelin ne kadar zamandir calistigi bilgisi
SELECT ID,NAME +' '+SURNAME AS PERSON,INDATE,OUTDATE,
CASE
	WHEN OUTDATE IS NULL THEN 'DEVAM EDÝYOR'
	WHEN OUTDATE IS NOT NULL THEN 'ÝSTEN AYRILDI'
END DURUM,
CASE
	WHEN OUTDATE IS NULL THEN DATEDIFF(MONTH,INDATE,GETDATE())
	WHEN OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,INDATE,OUTDATE) 
END SÜRE
FROM PERSON

-- Þirket 5.yil hediyesi olarak herkesin isim soyisim bas harflerinin oldugu 
-- ajanda hediye edecektir. Ýsim soyisim bas harfleri ve kac adet olduðu bilgisini
-- getiren kodu yazýnýz.
SELECT LEFT(NAME,1) +'.'+LEFT(SURNAME,1)+'.' AS SHORTNAME, 
COUNT(*) PERCOUNT FROM PERSON 
GROUP BY LEFT(NAME,1) +'.'+LEFT(SURNAME,1)+'.'

-- Maas ortalamasi 5500'den fazla olan departmanlar
SELECT DEP.DEPARTMENT, ROUND(AVG(SALARY),0) AS AVGSALARY FROM PERSON PER
INNER JOIN DEPARTMENT DEP ON PER.DEPARTMENTID = DEP.ID
GROUP BY DEP.DEPARTMENT
HAVING AVG(SALARY) > 5500

-- Departmanlarýn ay bazinda ortalama kidemi 
-- (Yani departman total calisma ayý / total kisi sayisi)
SELECT DEPARTMENT,AVG(SÜRE) AS AVG_EXP
FROM
(SELECT DEP.DEPARTMENT,
CASE
	WHEN OUTDATE IS NULL THEN DATEDIFF(MONTH,INDATE,GETDATE())
	WHEN OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,INDATE,OUTDATE) 
END SÜRE 
FROM PERSON PER INNER JOIN DEPARTMENT DEP 
ON PER.DEPARTMENTID = DEP.ID) T GROUP BY DEPARTMENT

-- Coklu JOIN kullanimina iyi bir örnek 

-- Her personelin ad, pozisyonunu, 
-- bagli olduðu birim yöneticisinin adý ve yöneticinin pozisyonunu getiren kod
SELECT PER.NAME +' '+PER.SURNAME AS PERSON,POS.POSITION,
P2.NAME +' '+P2.SURNAME AS MÜDÜR, POS2.POSITION AS MANAGERPOSITION
FROM PERSON PER 
-- Bana PERSON tablosundaki POSITIONID bilgisinin POSITION tablosundaki kesisimine göre
-- çalisanlarýn pozisyon bilgisini al
INNER JOIN POSITION POS ON PER.POSITIONID = POS.ID
-- Bana MANAGERID'si kendi ID'si olan kiþileri al
INNER JOIN PERSON P2 ON PER.MANAGERID = P2.ID
-- Bana bu kisilerin POSITIONID'lerini POSITION tablosundan ID cakismasina göre cek al
INNER JOIN POSITION POS2 ON POS2.ID = P2.POSITIONID
WHERE PER.MANAGERID!='NULL'
ORDER BY PER.ID ASC

-- Notes from HNS. 
-- UpL.Date: 02/04/2022 
-- Source: Ömer Çolakoglu - Alistirmalarla SQL
