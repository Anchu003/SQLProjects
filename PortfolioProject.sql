use covids

select * from [dbo].[PortfolioProject]

/*

Cleaning Data in SQL Queries

*/


Select *
From covids.dbo.PortfolioProject

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From covids.dbo.PortfolioProject


Update PortfolioProject
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PortfolioProject
Add SaleDateConverted Date;

Update PortfolioProject
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From covids.dbo.PortfolioProject

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From covids.dbo.PortfolioProject
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From covids.dbo.PortfolioProject a
JOIN covids.dbo.PortfolioProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From covids.dbo.PortfolioProject a
JOIN covids.dbo.PortfolioProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From covids.dbo.PortfolioProject
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From covids.dbo.PortfolioProject


ALTER TABLE PortfolioProject
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From covids.dbo.PortfolioProject





Select OwnerAddress
From covids.dbo.PortfolioProject


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From covids.dbo.PortfolioProject



ALTER TABLE PortfolioProject
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From covids.dbo.PortfolioProject




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From covids.dbo.PortfolioProject
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From covids.dbo.PortfolioProject


Update PortfolioProject
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From covids.dbo.PortfolioProject
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From covids.dbo.PortfolioProject




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From covids.dbo.PortfolioProject pp
where pp.[UniqueID ] = 2045;


ALTER TABLE covids.dbo.PortfolioProject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate