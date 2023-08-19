/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing;



-- Standardize Date Format 



Select SaleDateConverted
	, Convert(Date,Saledate)
From PortfolioProject.dbo.NashvilleHousing;


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);



-- Populate property Address data



Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID;



Select a.ParcelID
	, a.PropertyAddress
	, b.ParcelID
	, b.PropertyAddress
	, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ];



-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

-- Using Substrings and CharIndex

Select 
	  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
-- , CHARINDEX(',', PropertyAddress)
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));


Select *
From PortfolioProject.dbo.NashvilleHousing;




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing;


-- Using ParseName and Replace instead of Substrings


Select
	  PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
	, PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
	, PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1);

Select *
From PortfolioProject.dbo.NashvilleHousing;




-- Change Y and N to Yes and No in "Sold as Vacant" field



Select 
	  Distinct(SoldAsVacant)
	, Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2;



Select 
	  SoldAsVacant
	, Case When SoldAsVacant = 'Y' Then 'Yes'
		   When SoldAsVacant = 'N' Then 'No'
		   ELSE SoldAsVacant 
		   END
	  From PortfolioProject.dbo.NashvilleHousing;


Update NashvilleHousing
Set SoldAsVacant =
	 Case When SoldAsVacant = 'Y' Then 'Yes'
		   When SoldAsVacant = 'N' Then 'No'
		   ELSE SoldAsVacant 
		   END;



-- Removing Duplicates 


WITH RowNumCTE AS (
Select *
	, ROW_NUMBER() Over (
	Partition By  ParcelID
				, PropertyAddress
				, SalePrice
				, SaleDate
				, LegalReference
				Order By
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress;



Select *
From PortfolioProject.dbo.NashvilleHousing;




-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing;


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column 
	  OwnerAddress
	, TaxDistrict
	, PropertyAddress
	, SaleDate;


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column 
	  SaleDate;