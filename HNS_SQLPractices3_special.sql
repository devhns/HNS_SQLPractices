-- Öðrencilerin cinsiyete göre daðýlýmý (Cinsiyeti Kadýn Erkek olarak adlandýrýnýz.)
SELECT CASE
WHEN GENDER = 'F' THEN 'Kadýn'
WHEN GENDER = 'M' THEN 'Erkek'
END AS GenderTR ,
COUNT(*) AS StudentCount
FROM STUDENTS
GROUP BY GENDER

-- Sayfa sayýsý 200'ü aþkýn olan kitap sayýsý
SELECT COUNT(*) FROM BOOKS
WHERE PAGECOUNT > 200

-- Mevcut kitaplarý sayfa sayýsý 100'den az, 200'den az, 300'den az ve
-- 400'den az þeklinde kategorilendirerek her kategoriye ait totalde
-- kaç kitap mevcut olduðu bilgisini getiriniz
SELECT COUNT(bookID) as BookCount,
CASE
WHEN PAGECOUNT<100 THEN '<100'
WHEN PAGECOUNT BETWEEN 100 AND 199 THEN '<200'
WHEN PAGECOUNT BETWEEN 200 AND 299 THEN '<300'
WHEN PAGECOUNT BETWEEN 300 AND 399 THEN '<400'
END AS PageK
FROM BOOKS
GROUP BY 
(CASE
WHEN PAGECOUNT<100 THEN '<100'
WHEN PAGECOUNT BETWEEN 100 AND 199 THEN '<200'
WHEN PAGECOUNT BETWEEN 200 AND 299 THEN '<300'
WHEN PAGECOUNT BETWEEN 300 AND 399 THEN '<400'
END)
ORDER BY PageK

-- Tekrar notu: PageK yine doðrudan GROUP BY içine olmadý o nedenle Aliase yerine 
-- kodu tekrar GB içine aktardýk.

-- Groupby içinde oluþturduðumuz bir Aliasý dinamik bir view aracýlýðýyla
-- kullanýp daha temiz bir kod yazabiliriz

-- Kitap ödünç alan öðrenciler için tanýnan ödünç almasý süresi 15 gün olarak
-- belirlenmiþtir. Aldýðý kitabý 15 günü aþmýþ sürede elinde tutan öðrencilerin
-- isim,soyisim, öðrenci bilgilerini getiriniz. Ýsim ve soyisim tek kolonda yer almalý.
-- Sýnýf bilgisini ise þube kodu ayrý kolonda olacak þekilde iki kolon
-- biçiminde getiriniz.
SELECT ST.name +' '+ST.surname AS NameSurname,
BO.name AS BookName, B.takenDate, B.broughtDate,
(SELECT LEFT(ST.CLASS,LEN(ST.CLASS)-1)) AS Class,
RIGHT(ST.CLASS,1) AS Code FROM STUDENTS AS ST 
INNER JOIN BORROWS AS B ON ST.STUDENTID = B.STUDENTID 
INNER JOIN  BOOKS AS BO  ON B.bookID = BO.bookID
WHERE DATEDIFF(DAY,takenDate,broughtDate)>12
ORDER BY takenDate

-- Yukarýdaki bilgilere dayanarak 15 gün aþýmý sonrasý öðrencilerden gün baþý 0.5C
-- alýndýðýna göre aþým yapan öðrencilerin borç tutarýný getiren kolonu ekleyiniz
SELECT ST.name +' '+ST.surname AS NameSurname,
BO.name AS BookName, B.takenDate, B.broughtDate,
(SELECT LEFT(ST.CLASS,LEN(ST.CLASS)-1)) AS Class,
RIGHT(ST.CLASS,1) AS Code,
DATEDIFF(DAY,takenDate,broughtDate) AS passTime,
(SELECT FORMAT (((DATEDIFF(DAY,takenDate,broughtDate)-15)*0.5),'C','en-US')) 
AS LibFines
FROM STUDENTS AS ST 
INNER JOIN BORROWS AS B ON ST.STUDENTID = B.STUDENTID 
INNER JOIN  BOOKS AS BO  ON B.bookID = BO.bookID
WHERE DATEDIFF(DAY,takenDate,broughtDate)>12
ORDER BY takenDate

-- 2015 yýlýnda okunan kitap türü ve kaç öðrencinin okuduðu bilgisi
SELECT  T.TYPEID,T.TNAME, COUNT(*) AS STUCOUNT FROM STUDENTS ST 
INNER JOIN BORROWS BR ON ST.STUDENTID = BR.STUDENTID
INNER JOIN BOOKS B ON BR.BOOKID = B.BOOKID 
INNER JOIN TYPES T ON B.TYPEID = T.TYPEID 
WHERE YEAR(BR.TAKENDATE)=2015
GROUP BY T.TYPEID, T.TNAME
ORDER BY STUCOUNT desc

-- Yýllara göre kaç farklý öðrencinin kitap ödünç aldýðý bilgisi
SELECT MIN(TAKENDATE), MAX(TAKENDATE) FROM BORROWS

SELECT
CASE 
WHEN YEAR(takenDate)=2015 THEN 2015
WHEN YEAR(takenDate)=2016 THEN 2016
WHEN YEAR(takenDate)=2017 THEN 2017 
END AS Yil, COUNT(DISTINCT(STUDENTID)) AS DIF_STUCOUNT
FROM BORROWS
GROUP BY (CASE 
WHEN YEAR(takenDate)=2015 THEN 2015
WHEN YEAR(takenDate)=2016 THEN 2016
WHEN YEAR(takenDate)=2017 THEN 2017
END)
ORDER BY Yil ASC

-- Total veriye dayanarak en fazla kitap ödünç alma bilgisi
-- yer alan ilk 3 öðrenciye ait ID, isim soyisim, kaç kitap ödünç aldýðý 
-- bilgisinin yer aldýðý kolanlarýn mevcut olduðu sorgu
SELECT TOP 3 ST.STUDENTID AS StudentID, ST.name+' '+ST.surname AS NameSurname,
COUNT(ST.STUDENTID) AS BookCount FROM BORROWS AS BR 
INNER JOIN STUDENTS AS ST ON BR.STUDENTID = ST.STUDENTID
GROUP BY ST.STUDENTID,ST.name+' '+ST.surname
ORDER BY BookCount DESC

-- Kontrol amacýyla Borrows tablosundan ID'sini bildiðimiz birkaç öðrenciyi sorguluyoruz
-- (En az kitap ödünç alan)
SELECT * FROM BORROWS
WHERE StudentID = 396

-- (En çok kitap ödünç alan)
SELECT * FROM BORROWS
WHERE StudentID = 499

-- Tüm veri bazýnda öðrenciler tarafýndan en fazla ödünç alýnan kitap bilgisi
SELECT TOP 1 COUNT(BR.bookID) AS BorrowCount,
B.name AS BookName FROM BORROWS AS BR 
INNER JOIN BOOKS AS B ON BR.bookID = B.bookID
GROUP BY BR.bookID, B.name

-- 2017 yýlýnda kitap türleri bazýnda kaç farklý öðrencinin okuma yaptýðý bilgisi
SELECT T.TypeID,T.tname AS Type,
COUNT(DISTINCT(BR.studentID)) AS StudentCount FROM BORROWS AS BR 
INNER JOIN BOOKS AS B ON BR.bookID = B.bookID 
INNER JOIN TYPES AS T ON B.typeID = T.typeID
WHERE YEAR(BR.takenDate) = 2017
GROUP BY T.typeID,T.tname
ORDER BY T.typeID



