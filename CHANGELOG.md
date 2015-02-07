# 1.0.0

* New chart type: StackedBarChartCategorical to go with its percentage cousing.
* Improved display of table of contents.
* Improved display of box plot groups: Auto scale charts to make best use of
  screen space when there are extreme outliers.
* Automatically limit the number of distinct values in a categorical data series
  to reduce number of items in categorical charts. Group less frequent observations
  under '[Other]'.
* Made charts wider to use more screen space.
* Scroll contingency tables horizontally if they are too wide.
* Improved label sorter for categorical values. When working with a mix of
  numeric and non-numeric labels, sort non-numeric ones at the end.
* Improved performance by caching a lot of computed data.
* Removed obsolete files.
* Improved documentation.
* Various bug fixes.

### 0.2.3

* Don't show all explorations by default. Takes too long when having 100
  explorations to render. Instead show univariate explorations by default
  and bivariate explorations on demand.

### 0.2.2

* Fixed file inclusion bug that prevented loading of Gem

### 0.2.1

* Fixed a bug
* Updated documentation

## 0.2.0

* Improvements to charts.
* Sort labels for categorical data.
* Improved table of contents at top of page.
* Improved presentation of contingency table.
* Avoid division by zero when given a data series with all '0' values.
* Improved performance of table rendering.
* Added `#number_of_values` for integration with Filterrific gem.

## 0.1.0

* Is now being used in a production app, however no documentation yet.

### 0.0.1

* Initial release
