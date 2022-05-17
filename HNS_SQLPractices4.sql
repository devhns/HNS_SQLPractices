--Hangi �ehrin ne kadarl�k sat�� yapt��� bilgisi
SELECT CITY,SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
GROUP BY CITY
ORDER BY CITY ASC

--�ehirlerin aylara g�re yapt��� toplam  sat�� miktar�
SELECT CITY,MONTH_,SUM(LINETOTAL) as TOTALSALE FROM SALEORDERS
GROUP BY MONTH_,CITY
ORDER BY CITY,MONTH_ ASC

--�ehirler en �ok hangi g�nde sat�� yapm��
SELECT CITY,DAYOFWEEK_,SUM(LINETOTAL) as TOTALSALE FROM SALEORDERS
GROUP BY DAYOFWEEK_,CITY
ORDER BY CITY,DAYOFWEEK_ ASC

--�ehirlerin g�nlere g�re yapt��� total sat�� 
--Alias kullanmay� unutma ��nk� GROUP BY ile de�il Alias ile S dedi�imiz SALEORDERS 
--tablosundan gelen CITY de�erini where ko�ulu i�ine koyarak bizim totalini 
--bulmu� oldu�umuz �ehir ile denkledik bu sayede asl�nda gruplam�� gibi olduk
--Yani bize d�nen her �ehir i�in 7 s�tun de�erini de buldu�umuz bir sat�r olu�turduk
SELECT DISTINCT(CITY),
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND DAYOFWEEK_ = '01.PZT' ) 
AS PAZARTES�,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '02.SAL') 
AS SALI,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '03.�AR') 
AS �AR�AMBA,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '04.PER') 
AS PER�EMBE,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '05.CUM') 
AS CUMA,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '06.CMT') 
AS CUMARTES�,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '07.PAZ') 
AS PAZAR
FROM SALEORDERS S
ORDER BY S.CITY 

--Her ilin en �ok satan ilk 5 kategorisi
--Buna benzer ko�ullara sahip TOP X durumlar�nda CROSS APPLY d���n�lmelidir 
--�rne�in bir �irketin her b�l�m�ndeki en iyi 2 �al��an
--Ya da x okulundaki ��rencilerin k�t�phaneye giri� yapt��� son 2 tarih
SELECT S.CITY, S1.CATEGORY1, SUM(S1.TOTALSALE) AS TOTALSALE
FROM SALEORDERS S
CROSS APPLY(SELECT TOP 5 CATEGORY1, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY GROUP BY CATEGORY1 ORDER BY 2 DESC) S1
GROUP BY S.CITY,S1.CATEGORY1
ORDER BY S.CITY, SUM(S1.TOTALSALE) DESC

--Her ilin en �ok satan 3 kategorisi ve onun 3 alt kategorisi 
--Yani bir CROSS APLY tablosu olu�turup ordaki bilgileri de kullanarak
--di�er bir CROSS APPLY k�r�l�m� yoluyla subkategori sorgusu haz�rlayaca��z
SELECT S.CITY, S1.CATEGORY1, S2.CATEGORY2, SUM(S1.TOTALSALE) AS TOTALSALE
FROM SALEORDERS S
CROSS APPLY(SELECT TOP 3 CATEGORY1, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY GROUP BY CATEGORY1 ORDER BY 2 DESC) S1
CROSS APPLY(SELECT TOP 3 CATEGORY2, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY AND CATEGORY1=S1.CATEGORY1 GROUP BY CATEGORY2 ORDER BY 2 DESC) S2
GROUP BY S.CITY,S1.CATEGORY1,S2.CATEGORY2
ORDER BY 1,2,4 DESC

-- Cities tablosunun bir kopyas�n� olu�turmak
CREATE TABLE CITIES2 (ID INT IDENTITY (1,1), COUNTRYID INT, CITY VARCHAR(50))

INSERT INTO CITIES2 (COUNTRYID,CITY) SELECT COUNTRYID,CITY FROM CITIES

SELECT * FROM CITIES2
--// �nemli olan iki taraf�nda tip olarak uyu�mas�, kolon isimlerinin ayn� olmas�na 
--gerek yok.

--Ya da �zellikle �ok kolonlu tablolar i�in
--CITIES -- Script Table As -- Create to - New Edi. diyerek scriptten tablo ad�n� 
--de�i�tirip yazmakla u�ra�madan kodu �al��t�r�p i�eri�i ayn� yeni bir tablo olu�turabiliriz.
--Tabi verileri tekrar eklemek gerek.

--3. yolda birebir t�m kolon ve tipler aktar�l�r. Tek eksik Primary Key'in ayarlanmas�d�r.
SELECT * INTO CITIES3 FROM CITIES

--CTRL+H k�sayolu ile se�ili kod sat�r� i�indeki belli harfler ya da i�aretleri
--hedef harf ya da i�aretle de�i�tirebiliriz

--�li�kisel tablolar� kullanarak hangi �ehirde ne kadar sat�� yap�ld��� bilgisi
--JOINLER
SET STATISTICS IO ON
SELECT CT.CITY,SUM(OD.TOTALPRICE) AS TOPLAMSAT�S
FROM ORDERS OD INNER JOIN ADDRESS AD ON OD.ADDRESSID = AD.ID 
INNER JOIN CITIES CT ON AD.CITYID = CT.ID 
GROUP BY CT.CITY
--SubQuery
SET STATISTICS IO ON
SELECT *,
(SELECT SUM(TOTALPRICE) FROM ORDERS WHERE ADDRESSID 
IN (SELECT ID FROM ADDRESS WHERE CITYID = C.ID))
FROM CITIES C

--Avantajl� olan hem temiz kod hem de okunan pageden kaynakl� JOIN'lerdir.
--Kontrol i�in SET STATISTICS IO ON dan loglar incelenir

--Her markan�n en �ok satan CATEGORY1 alan�
SELECT IT.BRAND, IT.CATEGORY1, SUM(LINETOTAL) AS TOPLAM
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.BRAND, IT.CATEGORY1

--Her kategorinin en �ok satan markas�
SELECT IT.CATEGORY1,IT.BRAND, SUM(LINETOTAL) AS TOPLAM
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.CATEGORY1, IT.BRAND
ORDER BY CATEGORY1

--Her �r�n min,max ve ortalama ne kadar fiyattan sat�lm��, ka� kez ve ka� adet sat�lm��
SELECT IT.BRAND, IT.CATEGORY1, OD.ITEMID, IT.ITEMNAME, COUNT(OD.ITEMID) AS SALECOUNT, 
SUM(OD.AMOUNT) AS SALEAMOUNT, MIN(OD.UNITPRICE) AS MINPRICE, 
MAX(OD.UNITPRICE) AS MAXPRICE, AVG(OD.UNITPRICE) AS AVGPRICE
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.BRAND, IT.CATEGORY1, OD.ITEMID, IT.ITEMNAME
ORDER BY IT.BRAND ASC, OD.ITEMID DESC

--M��terilerin sistemde kay�tl� ka� adet adresi oldu�u ve son adres bilgileri
SELECT U.ID, U.NAMESURNAME, 
(SELECT COUNT(*) FROM ADDRESS WHERE USERID= U.ID) AS ADDRESSCOUNT,
(SELECT ADDRESSTEXT FROM ADDRESS WHERE ID IN
(SELECT TOP 1 ADDRESSID FROM ORDERS WHERE USERID = U.ID ORDER BY DATE_ DESC)) AS LASTADDRESS
FROM USERS U 

--M��terilerin ka� adet adresi oldu�u, son adres bilgisi, �ehri, il�esi ve semti
-- Bir �nceki kodda oynama yaparak adres id bulup bunu dinamik view olarak ba�ka
--bir tabloyla joinleyip sonuca ula�t�k
SELECT DYN.NAMESURNAME, DYN.ADDRESSCOUNT, A.ADDRESSTEXT, C.CITY, T.TOWN, D.DISTRICT FROM (
SELECT U.ID, U.NAMESURNAME, 
(SELECT COUNT(*) FROM ADDRESS WHERE USERID= U.ID) AS ADDRESSCOUNT,
(SELECT TOP 1 ADDRESSID FROM ORDERS WHERE USERID = U.ID ORDER BY DATE_ DESC) AS LASTADDRESSID
FROM USERS U ) DYN
INNER JOIN ADDRESS A ON A.ID = DYN.LASTADDRESSID
INNER JOIN CITIES C ON C.ID = A.CITYID
INNER JOIN TOWNS T ON T.ID = A.TOWNID
INNER JOIN DISTRICTS D ON D.ID = A.DISTRICTID
ORDER BY NAMESURNAME

--Ocak ay�nda en az 10 g�n boyunca 500 TL ve alt� sipari� verilen �ehirler
SELECT CITY, COUNT(*) AS COUNT FROM
(
SELECT C.CITY,CONVERT(DATE, O.DATE_) AS DAYOFMONTH_, SUM(O.TOTALPRICE) AS TOTAL FROM ORDERS O 
INNER JOIN ADDRESS AD ON O.ADDRESSID = AD.ID
INNER JOIN CITIES C ON AD.CITYID = C.ID
WHERE O.DATE_ BETWEEN '2019-01-01' AND '2019-01-31 23:59'
GROUP BY C.CITY,CONVERT(DATE, O.DATE_)
HAVING SUM(O.TOTALPRICE)<500
) DYN
GROUP BY CITY
HAVING COUNT(CITY)>10