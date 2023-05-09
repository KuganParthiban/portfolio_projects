SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing

-- Convert date format 
SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT *
FROM NashvilleHousing






-- Populate Property Address Data

SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


--- ParcelID is duplicated, there are adresss in the duplicated ParcelID
--- When the ParcelId is duplicate and has address, fill na with the address wjich has the same ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjectSQL.dbo.NashvilleHousing a
JOIN PortfolioProjectSQL.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjectSQL.dbo.NashvilleHousing a
JOIN PortfolioProjectSQL.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




-- Breaking out Address into individual data (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjectSQL.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City

From PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing




-- Breaking out Owner Address into Address, City and State

SELECT OwnerAddress
FROM PortfolioProjectSQL.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM PortfolioProjectSQL.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProjectSQL.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-- Remove Duplicates 
--- Create CTE 
WITH RowNumCTE AS(
SELECT *
,ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,				
LegalReference
ORDER BY 
UniqueID) 
row_num

FROM PortfolioProjectSQL.dbo.NashvilleHousing
-- order by ParcelID
)



-- Remove Duplicates
DELETE
FROM RowNumCTE
WHERE row_num > 1 
--ORDER BY PropertyAddress


--- Delete Unused Columns
SELECT *
FROM PortfolioProjectSQL.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProjectSQL.dbo.NashvilleHousing
DROP COLUMN SaleDate


