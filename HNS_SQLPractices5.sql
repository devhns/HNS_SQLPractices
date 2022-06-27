-- Her markadan ka� adet araba oldu�u bilgisi
SELECT BRAND,COUNT(*) FROM WEBOFFERS
GROUP BY BRAND 
ORDER BY 2 DESC

--Her markadan toplamda ka� ara� var ve toplam�n y�zde ka��na tekab�l etmektedir
SELECT BRAND,COUNT(*) AS M�KTAR, 
ROUND(CONVERT(FLOAT,COUNT(*))/(SELECT COUNT(*) FROM WEBOFFERS)*100,2) AS YUZDE
FROM WEBOFFERS 
GROUP BY BRAND 
ORDER BY 2 DESC 

--Hangi �ehirde ka� adet ilan mevcut
SELECT CT.ID,CT.CITY,COUNT(*) AS MIKTAR
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID
GROUP BY CT.ID,CT.CITY
ORDER BY 3 DESC

-- Volkswagen marka Passat model Dizel yak�t kullanan sahibinden sat�l�k 2014-2018 model
-- Otomatik ya da yar� otomatik vites olan ilanlara dair bilgiler 
SELECT CT.CITY, US.NAMESURNAME, WB.BRAND, WB.MODEL, WB.FUEL, 
WB.FROMWHO, WB.YEAR_, WB.SHIFTTYPE, WB.PRICE
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID
INNER JOIN USER_ AS US ON  WB.USERID = US.ID
WHERE WB.CITYID = 34 AND
WB.Brand = 'Volkswagen' AND WB.Model = 'Passat'
AND WB.Fromwho = 'Sahibinden'
AND (WB.YEAR_ BETWEEN 2014 AND 2018)
AND WB.SHIFTTYPE IN ('Otomatik Vites', 'Yar� Otomatik Vites')
AND WB.FUEL = 'Dizel'
ORDER BY WB.KM,WB.PRICE DESC

-- BMW model �stanbul, �zmir, Ankara illerine ait ara�lar�n ilanlar�n� getiren sorgu
-- Mant�ksal olarak alt sorgu yanl�� ��nk� biz 
-- sanki bir sitede �oklu se�im yapm���z ancak her birini
-- kategorik ayr���mla g�z�k�yormu� gibi sorgulamak istiyoruz
-- oysa burada in ile sadece var m� yok mu sorgulamas� yap�yoruz ve string ar�yoruz
SELECT US.NAMESURNAME, CT.CITY, DS.DISTRICT, WB.COLOR, WB.FUEL,
WB.TITLE, WB.BRAND, WB.MODEL, WB.PRICE, WB.YEAR_
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID 
INNER JOIN USER_ AS US ON US.ID = WB.USERID INNER JOIN DISTRICT AS DS
ON DS.ID = WB.DISTRICTID
WHERE WB.BRAND = 'BMW' AND CITY IN ('Ankara', '�stanbul', '�zmir')

-- Buna ��z�m olarak T-SQL'e �zg� string split fonk. kullan�yoruz
SELECT US.NAMESURNAME, CT.CITY, DS.DISTRICT, WB.COLOR,
WB.TITLE, WB.BRAND, WB.MODEL, WB.PRICE, WB.YEAR_
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID 
INNER JOIN USER_ AS US ON US.ID = WB.USERID INNER JOIN DISTRICT AS DS
ON DS.ID = WB.DISTRICTID
WHERE WB.BRAND = 'BMW' 
AND CT.CITY IN (SELECT value FROM string_split('Ankara,�stanbul,�zmir',','))