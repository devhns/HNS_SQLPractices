-- Her markadan kaç adet araba olduðu bilgisi
SELECT BRAND,COUNT(*) FROM WEBOFFERS
GROUP BY BRAND 
ORDER BY 2 DESC

--Her markadan toplamda kaç araç var ve toplamýn yüzde kaçýna tekabül etmektedir
SELECT BRAND,COUNT(*) AS MÝKTAR, 
ROUND(CONVERT(FLOAT,COUNT(*))/(SELECT COUNT(*) FROM WEBOFFERS)*100,2) AS YUZDE
FROM WEBOFFERS 
GROUP BY BRAND 
ORDER BY 2 DESC 

--Hangi þehirde kaç adet ilan mevcut
SELECT CT.ID,CT.CITY,COUNT(*) AS MIKTAR
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID
GROUP BY CT.ID,CT.CITY
ORDER BY 3 DESC

-- Volkswagen marka Passat model Dizel yakýt kullanan sahibinden satýlýk 2014-2018 model
-- Otomatik ya da yarý otomatik vites olan ilanlara dair bilgiler 
SELECT CT.CITY, US.NAMESURNAME, WB.BRAND, WB.MODEL, WB.FUEL, 
WB.FROMWHO, WB.YEAR_, WB.SHIFTTYPE, WB.PRICE
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID
INNER JOIN USER_ AS US ON  WB.USERID = US.ID
WHERE WB.CITYID = 34 AND
WB.Brand = 'Volkswagen' AND WB.Model = 'Passat'
AND WB.Fromwho = 'Sahibinden'
AND (WB.YEAR_ BETWEEN 2014 AND 2018)
AND WB.SHIFTTYPE IN ('Otomatik Vites', 'Yarý Otomatik Vites')
AND WB.FUEL = 'Dizel'
ORDER BY WB.KM,WB.PRICE DESC

-- BMW model Ýstanbul, Ýzmir, Ankara illerine ait araçlarýn ilanlarýný getiren sorgu
-- Mantýksal olarak alt sorgu yanlýþ çünkü biz 
-- sanki bir sitede çoklu seçim yapmýþýz ancak her birini
-- kategorik ayrýþýmla gözüküyormuþ gibi sorgulamak istiyoruz
-- oysa burada in ile sadece var mý yok mu sorgulamasý yapýyoruz ve string arýyoruz
SELECT US.NAMESURNAME, CT.CITY, DS.DISTRICT, WB.COLOR, WB.FUEL,
WB.TITLE, WB.BRAND, WB.MODEL, WB.PRICE, WB.YEAR_
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID 
INNER JOIN USER_ AS US ON US.ID = WB.USERID INNER JOIN DISTRICT AS DS
ON DS.ID = WB.DISTRICTID
WHERE WB.BRAND = 'BMW' AND CITY IN ('Ankara', 'Ýstanbul', 'Ýzmir')

-- Buna çözüm olarak T-SQL'e özgü string split fonk. kullanýyoruz
SELECT US.NAMESURNAME, CT.CITY, DS.DISTRICT, WB.COLOR,
WB.TITLE, WB.BRAND, WB.MODEL, WB.PRICE, WB.YEAR_
FROM WEBOFFERS AS WB INNER JOIN CITY AS CT ON WB.CITYID = CT.ID 
INNER JOIN USER_ AS US ON US.ID = WB.USERID INNER JOIN DISTRICT AS DS
ON DS.ID = WB.DISTRICTID
WHERE WB.BRAND = 'BMW' 
AND CT.CITY IN (SELECT value FROM string_split('Ankara,Ýstanbul,Ýzmir',','))