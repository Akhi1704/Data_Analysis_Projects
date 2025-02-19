### Nashville Housing Data Analysis Project

- **Nashville_Housing**
  - `Nashville_Housing.ipynb`: Jupyter Notebook containing the data analysis and visualizations for the Nashville housing dataset.
  - `data/`: Directory containing the dataset files for the Nashville housing project.
  - `images/`: Directory containing saved plot images for the Nashville housing project.
  - `README.md`: Project-specific README file for the Nashville housing analysis.

#### Visualizations

1. **Distribution of Sale Prices**
   ![Distribution of Sale Prices](Nashville_Housing/images/sale_price_distribution.png)

2. **Number of Property Sales by Year**
   ![Number of Property Sales by Year](Nashville_Housing/images/sales_by_year.png)

3. **Sale Prices by Property Type**
   ![Sale Prices by Property Type](Nashville_Housing/images/sale_prices_by_property_type.png)

4. **Sale Price vs. Property Size**
   ![Sale Price vs. Property Size](Nashville_Housing/images/sale_price_vs_property_size.png)

5. **Correlation Matrix**
   ![Correlation Matrix](Nashville_Housing/images/correlation_matrix.png)

6. **Sales by Property Type**
   ![Sales by Property Type](Nashville_Housing/images/sales_by_property_type.png)

#### Analysis Summary

- **Distribution of Sale Prices**: Shows the frequency of different sale prices in the dataset.
- **Number of Property Sales by Year**: Displays the number of property sales for each year.
- **Sale Prices by Property Type**: Compares sale prices across different property types.
- **Sale Price vs. Property Size**: Examines the relationship between property size and sale price.
- **Correlation Matrix**: Visualizes the relationships between numerical variables.
- **Sales by Property Type**: Bar plot of sales by property type, filtered by a specified threshold.

#### How to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Akhi1704/DataAnalysis_Projects.git
   ```
2. Navigate to the project directory:
   ```bash
   cd DataAnalysis_Projects/Nashville_Housing
   ```
3. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```
4. Open the Jupyter Notebook:
   ```bash
   jupyter notebook Nashville_Housing.ipynb
   ```

#### Dataset

The dataset used in this project contains information about property sales in Nashville, including sale prices, property types, sale years, and property sizes.


#### SQL Data Cleaning

The `nashville_housing.sql` file contains SQL scripts used to clean the raw dataset. Key cleaning steps include:
- Removing duplicates
- Handling missing values
- Standardizing date formats
- Breaking out addresses into individual columns (Address, City, State)
- Changing 'Y' and 'N' to 'Yes' and 'No' in the SoldAsVacant column

The cleaned datasets are stored in the `cleaned_data/` directory.


## License

This project is licensed under the MIT License.

```

