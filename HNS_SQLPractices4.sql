--Hangi þehrin ne kadarlýk satýþ yaptýðý bilgisi
SELECT CITY,SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
GROUP BY CITY
ORDER BY CITY ASC

--Þehirlerin aylara göre yaptýðý toplam  satýþ miktarý
SELECT CITY,MONTH_,SUM(LINETOTAL) as TOTALSALE FROM SALEORDERS
GROUP BY MONTH_,CITY
ORDER BY CITY,MONTH_ ASC

--Þehirler en çok hangi günde satýþ yapmýþ
SELECT CITY,DAYOFWEEK_,SUM(LINETOTAL) as TOTALSALE FROM SALEORDERS
GROUP BY DAYOFWEEK_,CITY
ORDER BY CITY,DAYOFWEEK_ ASC

--Þehirlerin günlere göre yaptýðý total satýþ 
--Alias kullanmayý unutma çünkü GROUP BY ile deðil Alias ile S dediðimiz SALEORDERS 
--tablosundan gelen CITY deðerini where koþulu içine koyarak bizim totalini 
--bulmuþ olduðumuz þehir ile denkledik bu sayede aslýnda gruplamýþ gibi olduk
--Yani bize dönen her þehir için 7 sütun deðerini de bulduðumuz bir satýr oluþturduk
SELECT DISTINCT(CITY),
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND DAYOFWEEK_ = '01.PZT' ) 
AS PAZARTESÝ,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '02.SAL') 
AS SALI,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '03.ÇAR') 
AS ÇARÞAMBA,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '04.PER') 
AS PERÞEMBE,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '05.CUM') 
AS CUMA,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '06.CMT') 
AS CUMARTESÝ,
(SELECT SUM(LINETOTAL) FROM SALEORDERS WHERE CITY=S.CITY AND  DAYOFWEEK_ = '07.PAZ') 
AS PAZAR
FROM SALEORDERS S
ORDER BY S.CITY 

--Her ilin en çok satan ilk 5 kategorisi
--Buna benzer koþullara sahip TOP X durumlarýnda CROSS APPLY düþünülmelidir 
--Örneðin bir þirketin her bölümündeki en iyi 2 çalýþan
--Ya da x okulundaki öðrencilerin kütüphaneye giriþ yaptýðý son 2 tarih
SELECT S.CITY, S1.CATEGORY1, SUM(S1.TOTALSALE) AS TOTALSALE
FROM SALEORDERS S
CROSS APPLY(SELECT TOP 5 CATEGORY1, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY GROUP BY CATEGORY1 ORDER BY 2 DESC) S1
GROUP BY S.CITY,S1.CATEGORY1
ORDER BY S.CITY, SUM(S1.TOTALSALE) DESC

--Her ilin en çok satan 3 kategorisi ve onun 3 alt kategorisi 
--Yani bir CROSS APLY tablosu oluþturup ordaki bilgileri de kullanarak
--diðer bir CROSS APPLY kýrýlýmý yoluyla subkategori sorgusu hazýrlayacaðýz
SELECT S.CITY, S1.CATEGORY1, S2.CATEGORY2, SUM(S1.TOTALSALE) AS TOTALSALE
FROM SALEORDERS S
CROSS APPLY(SELECT TOP 3 CATEGORY1, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY GROUP BY CATEGORY1 ORDER BY 2 DESC) S1
CROSS APPLY(SELECT TOP 3 CATEGORY2, SUM(LINETOTAL) AS TOTALSALE FROM SALEORDERS
WHERE CITY=S.CITY AND CATEGORY1=S1.CATEGORY1 GROUP BY CATEGORY2 ORDER BY 2 DESC) S2
GROUP BY S.CITY,S1.CATEGORY1,S2.CATEGORY2
ORDER BY 1,2,4 DESC

-- Cities tablosunun bir kopyasýný oluþturmak
CREATE TABLE CITIES2 (ID INT IDENTITY (1,1), COUNTRYID INT, CITY VARCHAR(50))

INSERT INTO CITIES2 (COUNTRYID,CITY) SELECT COUNTRYID,CITY FROM CITIES

SELECT * FROM CITIES2
--// Önemli olan iki tarafýnda tip olarak uyuþmasý, kolon isimlerinin ayný olmasýna 
--gerek yok.

--Ya da özellikle çok kolonlu tablolar için
--CITIES -- Script Table As -- Create to - New Edi. diyerek scriptten tablo adýný 
--deðiþtirip yazmakla uðraþmadan kodu çalýþtýrýp içeriði ayný yeni bir tablo oluþturabiliriz.
--Tabi verileri tekrar eklemek gerek.

--3. yolda birebir tüm kolon ve tipler aktarýlýr. Tek eksik Primary Key'in ayarlanmasýdýr.
SELECT * INTO CITIES3 FROM CITIES

--CTRL+H kýsayolu ile seçili kod satýrý içindeki belli harfler ya da iþaretleri
--hedef harf ya da iþaretle deðiþtirebiliriz

--Ýliþkisel tablolarý kullanarak hangi þehirde ne kadar satýþ yapýldýðý bilgisi
--JOINLER
SET STATISTICS IO ON
SELECT CT.CITY,SUM(OD.TOTALPRICE) AS TOPLAMSATÝS
FROM ORDERS OD INNER JOIN ADDRESS AD ON OD.ADDRESSID = AD.ID 
INNER JOIN CITIES CT ON AD.CITYID = CT.ID 
GROUP BY CT.CITY
--SubQuery
SET STATISTICS IO ON
SELECT *,
(SELECT SUM(TOTALPRICE) FROM ORDERS WHERE ADDRESSID 
IN (SELECT ID FROM ADDRESS WHERE CITYID = C.ID))
FROM CITIES C

--Avantajlý olan hem temiz kod hem de okunan pageden kaynaklý JOIN'lerdir.
--Kontrol için SET STATISTICS IO ON dan loglar incelenir

--Her markanýn en çok satan CATEGORY1 alaný
SELECT IT.BRAND, IT.CATEGORY1, SUM(LINETOTAL) AS TOPLAM
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.BRAND, IT.CATEGORY1

--Her kategorinin en çok satan markasý
SELECT IT.CATEGORY1,IT.BRAND, SUM(LINETOTAL) AS TOPLAM
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.CATEGORY1, IT.BRAND
ORDER BY CATEGORY1

--Her ürün min,max ve ortalama ne kadar fiyattan satýlmýþ, kaç kez ve kaç adet satýlmýþ
SELECT IT.BRAND, IT.CATEGORY1, OD.ITEMID, IT.ITEMNAME, COUNT(OD.ITEMID) AS SALECOUNT, 
SUM(OD.AMOUNT) AS SALEAMOUNT, MIN(OD.UNITPRICE) AS MINPRICE, 
MAX(OD.UNITPRICE) AS MAXPRICE, AVG(OD.UNITPRICE) AS AVGPRICE
FROM ORDERDETAILS OD INNER JOIN ITEMS IT ON OD.ITEMID = IT.ID
GROUP BY IT.BRAND, IT.CATEGORY1, OD.ITEMID, IT.ITEMNAME
ORDER BY IT.BRAND ASC, OD.ITEMID DESC

--Müþterilerin sistemde kayýtlý kaç adet adresi olduðu ve son adres bilgileri
SELECT U.ID, U.NAMESURNAME, 
(SELECT COUNT(*) FROM ADDRESS WHERE USERID= U.ID) AS ADDRESSCOUNT,
(SELECT ADDRESSTEXT FROM ADDRESS WHERE ID IN
(SELECT TOP 1 ADDRESSID FROM ORDERS WHERE USERID = U.ID ORDER BY DATE_ DESC)) AS LASTADDRESS
FROM USERS U 

--Müþterilerin kaç adet adresi olduðu, son adres bilgisi, þehri, ilçesi ve semti
-- Bir önceki kodda oynama yaparak adres id bulup bunu dinamik view olarak baþka
--bir tabloyla joinleyip sonuca ulaþtýk
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

--Ocak ayýnda en az 10 gün boyunca 500 TL ve altý sipariþ verilen þehirler
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