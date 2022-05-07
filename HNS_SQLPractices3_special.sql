-- ��rencilerin cinsiyete g�re da��l�m� (Cinsiyeti Kad�n Erkek olarak adland�r�n�z.)
SELECT CASE
WHEN GENDER = 'F' THEN 'Kad�n'
WHEN GENDER = 'M' THEN 'Erkek'
END AS GenderTR ,
COUNT(*) AS StudentCount
FROM STUDENTS
GROUP BY GENDER

-- Sayfa say�s� 200'� a�k�n olan kitap say�s�
SELECT COUNT(*) FROM BOOKS
WHERE PAGECOUNT > 200

-- Mevcut kitaplar� sayfa say�s� 100'den az, 200'den az, 300'den az ve
-- 400'den az �eklinde kategorilendirerek her kategoriye ait totalde
-- ka� kitap mevcut oldu�u bilgisini getiriniz
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

-- Tekrar notu: PageK yine do�rudan GROUP BY i�ine olmad� o nedenle Aliase yerine 
-- kodu tekrar GB i�ine aktard�k.

-- Groupby i�inde olu�turdu�umuz bir Alias� dinamik bir view arac�l���yla
-- kullan�p daha temiz bir kod yazabiliriz

-- Kitap �d�n� alan ��renciler i�in tan�nan �d�n� almas� s�resi 15 g�n olarak
-- belirlenmi�tir. Ald��� kitab� 15 g�n� a�m�� s�rede elinde tutan ��rencilerin
-- isim,soyisim, ��renci bilgilerini getiriniz. �sim ve soyisim tek kolonda yer almal�.
-- S�n�f bilgisini ise �ube kodu ayr� kolonda olacak �ekilde iki kolon
-- bi�iminde getiriniz.
SELECT ST.name +' '+ST.surname AS NameSurname,
BO.name AS BookName, B.takenDate, B.broughtDate,
(SELECT LEFT(ST.CLASS,LEN(ST.CLASS)-1)) AS Class,
RIGHT(ST.CLASS,1) AS Code FROM STUDENTS AS ST 
INNER JOIN BORROWS AS B ON ST.STUDENTID = B.STUDENTID 
INNER JOIN  BOOKS AS BO  ON B.bookID = BO.bookID
WHERE DATEDIFF(DAY,takenDate,broughtDate)>12
ORDER BY takenDate

-- Yukar�daki bilgilere dayanarak 15 g�n a��m� sonras� ��rencilerden g�n ba�� 0.5C
-- al�nd���na g�re a��m yapan ��rencilerin bor� tutar�n� getiren kolonu ekleyiniz
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

-- 2015 y�l�nda okunan kitap t�r� ve ka� ��rencinin okudu�u bilgisi
SELECT  T.TYPEID,T.TNAME, COUNT(*) AS STUCOUNT FROM STUDENTS ST 
INNER JOIN BORROWS BR ON ST.STUDENTID = BR.STUDENTID
INNER JOIN BOOKS B ON BR.BOOKID = B.BOOKID 
INNER JOIN TYPES T ON B.TYPEID = T.TYPEID 
WHERE YEAR(BR.TAKENDATE)=2015
GROUP BY T.TYPEID, T.TNAME
ORDER BY STUCOUNT desc

-- Y�llara g�re ka� farkl� ��rencinin kitap �d�n� ald��� bilgisi
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

-- Total veriye dayanarak en fazla kitap �d�n� alma bilgisi
-- yer alan ilk 3 ��renciye ait ID, isim soyisim, ka� kitap �d�n� ald��� 
-- bilgisinin yer ald��� kolanlar�n mevcut oldu�u sorgu
SELECT TOP 3 ST.STUDENTID AS StudentID, ST.name+' '+ST.surname AS NameSurname,
COUNT(ST.STUDENTID) AS BookCount FROM BORROWS AS BR 
INNER JOIN STUDENTS AS ST ON BR.STUDENTID = ST.STUDENTID
GROUP BY ST.STUDENTID,ST.name+' '+ST.surname
ORDER BY BookCount DESC

-- Kontrol amac�yla Borrows tablosundan ID'sini bildi�imiz birka� ��renciyi sorguluyoruz
-- (En az kitap �d�n� alan)
SELECT * FROM BORROWS
WHERE StudentID = 396

-- (En �ok kitap �d�n� alan)
SELECT * FROM BORROWS
WHERE StudentID = 499

-- T�m veri baz�nda ��renciler taraf�ndan en fazla �d�n� al�nan kitap bilgisi
SELECT TOP 1 COUNT(BR.bookID) AS BorrowCount,
B.name AS BookName FROM BORROWS AS BR 
INNER JOIN BOOKS AS B ON BR.bookID = B.bookID
GROUP BY BR.bookID, B.name

-- 2017 y�l�nda kitap t�rleri baz�nda ka� farkl� ��rencinin okuma yapt��� bilgisi
SELECT T.TypeID,T.tname AS Type,
COUNT(DISTINCT(BR.studentID)) AS StudentCount FROM BORROWS AS BR 
INNER JOIN BOOKS AS B ON BR.bookID = B.bookID 
INNER JOIN TYPES AS T ON B.typeID = T.typeID
WHERE YEAR(BR.takenDate) = 2017
GROUP BY T.typeID,T.tname
ORDER BY T.typeID



