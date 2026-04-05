Select *FROM nashville_housing.dbo.housing_data

-- Standardizing Date Format

USE nashville_housing;

-- Add the new column SaleDateConverted if it doesn't exist
ALTER TABLE housing_data
ADD SaleDateConverted Date;

-- Update the SaleDateConverted column with the converted date from SaleDate
UPDATE housing_data
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Select SaleDateConverted and the converted SaleDate
SELECT saleDateConverted, CONVERT(Date, SaleDate)
FROM nashville_housing.dbo.housing_data;

-- Populating Poperty Address Data

Select *
From nashville_housing.dbo.housing_data
-- Where PropertyAddress is null
order by ParcelID

-- Replacing the column with null values with another column consisting values
Select a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From nashville_housing.dbo.housing_data a
JOIN nashville_housing.dbo.housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Updating the changed column
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From nashville_housing.dbo.housing_data a
JOIN nashville_housing.dbo.housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From nashville_housing.dbo.housing_data
-- Where PropertyAddress is null
-- order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address

-- Knowing the exact position of the comma in each row
-- CHARINDEX(',', PropertyAddress)

From nashville_housing.dbo.housing_data


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From nashville_housing.dbo.housing_data

-- Updating the changed columns into our table
USE nashville_housing;

ALTER TABLE housing_data
ADD PropertySplitAddress nvarchar(255);

UPDATE housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE housing_data
ADD PropertySplitCity nvarchar(255);

UPDATE housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

Select *
From nashville_housing.dbo.housing_data;

-- Doing the same for OwnerAddress column
Select OwnerAddress
From nashville_housing.dbo.housing_data;

-- Breaking the values at the comma to separate them into different columns
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From nashville_housing.dbo.housing_data;

-- Updating/Adding the changed columns 
ALTER TABLE housing_data
ADD OwnerSplitAddress nvarchar(255);

UPDATE housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing_data
ADD OwnerSplitCity nvarchar(255);

UPDATE housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing_data
ADD OwnerSplitState nvarchar(255);

UPDATE housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From nashville_housing.dbo.housing_data;

-- Changing 'Y' and 'N' to 'Yes' and 'No' in the SoldAsVacant column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From nashville_housing.dbo.housing_data
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From nashville_housing.dbo.housing_data;


Update housing_data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END 


-- Removing Duplicates
-- Creating CTE for simplifying the queries and accessing the duplicate rows
With RowNumCTE as (
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

From nashville_housing.dbo.housing_data
--order by ParcelID;
)
Delete
From RowNumCTE
where row_num > 1;


-- Deleting Unused Columns

ALTER TABLE housing_data
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress 

Select *
From nashville_housing.dbo.housing_data;