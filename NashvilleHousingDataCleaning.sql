/*

Cleaning data in SQL queries

*/

select * from MyProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, CONVERT(datetime, SaleDate)
from MyProject.dbo.NashvilleHousing

UPDATE MyProject.dbo.NashvilleHousing
set SaleDate = CONVERT(datetime, SaleDate)

ALTER TABLE MyProject.dbo.NashvilleHousing
ADD SaleDateConverted DATETIME;

UPDATE MyProject.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(datetime, SaleDate)


-------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select * 
from MyProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from MyProject.dbo.NashvilleHousing a
join MyProject.dbo.NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID  
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from MyProject.dbo.NashvilleHousing a
join MyProject.dbo.NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------

-- Breaking out address into Individual Columns (Address, City, States)

select PropertyAddress
from MyProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
-- order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from MyProject.dbo.NashvilleHousing

ALTER TABLE MyProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE MyProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE MyProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE MyProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select * from MyProject.dbo.NashvilleHousing

select OwnerAddress
from MyProject.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from MyProject.dbo.NashvilleHousing


ALTER TABLE MyProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE MyProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE MyProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE MyProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

UPDATE MyProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

UPDATE MyProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-------------------------------------------------------------------------------------------------

-- change Y and N to Yes and No in 'Sold as Vacent' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from MyProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
    when SoldAsVacant = 'N' then 'No'
    when SoldAsVacant = 'Y' then 'Yes'
    else SoldAsVacant
end 
from MyProject.dbo.NashvilleHousing

update MyProject.dbo.NashvilleHousing
set SoldAsVacant = 
case 
    when SoldAsVacant = 'N' then 'No'
    when SoldAsVacant = 'Y' then 'Yes'
    else SoldAsVacant
end 


-------------------------------------------------------------------------------------------------

-- Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                LegalReference
    ORDER BY   UniqueID
) row_num
from MyProject.dbo.NashvilleHousing
)

-- DELETE
-- from RowNumCTE
-- where row_num > 1

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress


-------------------------------------------------------------------------------------------------

-- remove Unused Columns

select * 
from MyProject.dbo.NashvilleHousing

ALTER TABLE MyProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE MyProject.dbo.NashvilleHousing
DROP COLUMN SaleDate