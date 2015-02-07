# -*- coding: utf-8 -*-

class RailsDataExplorer
  module Statistics

    # From http://en.wikipedia.org/wiki/Pearson's_chi-squared_test

    # Pearson's chi-squared test is used to assess whether paired observations on two
    # variables, expressed in a contingency table, are independent of each other.

    # An "observation" consists of the values of two outcomes and the null hypothesis
    # is that the occurrence of these outcomes is statistically independent. Each
    # observation is allocated to one cell of a two-dimensional array of cells (called
    # a contingency table) according to the values of the two outcomes.

    # Assumptions
    # -----------

    # The chi-squared test, when used with the standard approximation that a chi-
    # squared distribution is applicable, has the following assumptions:

    # * Simple random sample – The sample data is a random sampling from a fixed
    #   distribution or population where every collection of members of the population
    #   of the given sample size has an equal probability of selection. Variants of
    #   the test have been developed for complex samples, such as where the data is
    #   weighted. Other forms can be used such as purposive sampling.
    # * Sample size (whole table) – A sample with a sufficiently large size is assumed.
    #   If a chi squared test is conducted on a sample with a smaller size, then the
    #   chi squared test will yield an inaccurate inference. The researcher, by using
    #   chi squared test on small samples, might end up committing a Type II error.
    # * Expected cell count – Adequate expected cell counts. Some require 5 or more,
    #   and others require 10 or more. A common rule is 5 or more in all cells of a
    #   2-by-2 table, and 5 or more in 80% of cells in larger tables, but no cells
    #   with zero expected count. When this assumption is not met, Yates's Correction
    #   is applied.
    # * Independence – The observations are always assumed to be independent of each
    #   other. This means chi-squared cannot be used to test correlated data
    #   (like matched pairs or panel data). In those cases you might want to turn to
    #   McNemar's test.

    # Problems
    # --------

    # The approximation to the chi-squared distribution breaks down if expected
    # frequencies are too low. It will normally be acceptable so long as no more than
    # 20% of the events have expected frequencies below 5. Where there is only 1
    # degree of freedom, the approximation is not reliable if expected frequencies are
    # below 10. In this case, a better approximation can be obtained by reducing the
    # absolute value of each difference between observed and expected frequencies by
    # 0.5 before squaring; this is called Yates's correction for continuity.

    # In cases where the expected value, E, is found to be small (indicating a small
    # underlying population probability, and/or a small number of observations), the
    # normal approximation of the multinomial distribution can fail, and in such cases
    # it is found to be more appropriate to use the G-test, a likelihood ratio-based
    # test statistic. Where the total sample size is small, it is necessary to use an
    # appropriate exact test, typically either the binomial test or (for contingency
    # tables) Fisher's exact test. This test uses the conditional distribution of the
    # test statistic given the marginal totals; however, it does not assume that the
    # data were generated from an experiment in which the marginal totals are fixed
    # and is valid whether or not that is the case.
    class PearsonsChiSquaredIndependenceTest

      def initialize(data_matrix, min_probability = 0.05)
      end

      def compute
      end

    end
  end
end
