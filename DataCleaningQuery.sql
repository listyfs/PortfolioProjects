select *
from portfolios..NashvilleHousing
order by 1,2

--Standardize date format
select SaleDateConverted, convert (date, SaleDate)
from portfolios..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = convert (date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert (date, SaleDate)

-- Populate Property Address data

select *
from portfolios..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolios..NashvilleHousing a
join portfolios..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolios..NashvilleHousing a
join portfolios..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Out Address into Individual Columns (Address, City, State)

select *
from portfolios..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from portfolios..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select OwnerAddress
from portfolios..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

from portfolios..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from portfolios.dbo.NashvilleHousing
order by 1,2

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolios..NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'  
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
from portfolios.dbo.NashvilleHousing

UPDATE portfolios.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'  
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

-- Remove Duplicates

WITH RowNumCTE As (
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

from portfolios.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
where row_num >1
--order by [UniqueID ]

WITH RowNumCTE As (
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

from portfolios.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num >1
order by [UniqueID ]

--- Delete Unused Columns

Select *
from portfolios.dbo.NashvilleHousing

ALTER TABLE portfolios.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolios.dbo.NashvilleHousing
DROP COLUMN SaleDate

