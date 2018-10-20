# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                   Chron.jl                                    #
#                                                                               #
#       A two-part framework for (1) estimating eruption/deposition age         #
#  distributions from complex mineral age spectra and (2) subsequently building #
#  a stratigraphic age model based on those distributions. Each step relies on  #
#  a Markov-Chain Monte Carlo model.                                            #
#                                                                               #
#    The first model uses an informative prior distribution to estimate the     #
#  times of first (i.e., saturation) and last  mineral crystallization (i.e.,   #
#  eruption/deposition).                                                        #
#                                                                               #
#    The second model uses the estimated (posterior) eruption/deposition ages   #
#  distributions along with the constraint of stratigraphic superposition to    #
#  produce an age-depth model                                                   #
#                                                                               #
#   Last modified by C. Brenhin Keller 2018-04-09                               #
#                                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

__precompile__()

module Chron

    # Backwards compatibility
    using Compat
    # Forwards compatibility
    if VERSION>=v"0.7"
        using Statistics
        using StatsBase
        using DelimitedFiles
        using SpecialFunctions
    end

    # Basic statistics and UI resources
    using StatsBase: fit, Histogram, percentile
    using ProgressMeter: @showprogress
    using LsqFit: curve_fit
    using KernelDensity: kde
    using Interpolations

    # Weighted mean, etc
    include("Utilities.jl");
    # Functions for estimating extrema of a finite-range distribution
    include("DistMetropolis.jl");
    # Functions for stratigraphic modelling
    include("StratMetropolis.jl");

    # Higher-level functions for fitting and plotting
    using Colors: RGB, N0f8
    include("Colormaps.jl");

    using Plots; gr();
    include("Fitplot.jl");

    # Structs
    export StratAgeData, HiatusData, StratAgeModelConfiguration, StratAgeModel

    # High-level functions
    export  StratMetropolis, StratMetropolisHiatus,
        StratMetropolisDist, StratMetropolisDistHiatus,
        tMinDistMetropolis, metropolis_minmax_cryst,
        tMinDistMetropolisLA, metropolis_minmax_cryst_LA,
        check_dist_LL, check_cryst_LL,
        bilinear_exponential, bilinear_exponential_LL,
        plot_rankorder_errorbar,
        BootstrapCrystDistributionKDE,
        BootstrapCrystDistributionKDEfromStrat


    # Utility functions
    export nanminimum, nanmaximum, nanrange, pctile, nanmedian, nanmean, nanstd,
        linsp, linterp1s, linterp1, cntr, gwmean, awmean,
        normpdf, normcdf, norm_quantile,
        findclosest, findclosestbelow, findclosestabove,
        draw_from_distribution, fill_from_distribution

    # Colormaps
    export viridis, inferno, plasma, magma, fire

    # Distributions
    export UniformDistribution, TriangularDistribution, HalfNormalDistribution, TruncatedNormalDistribution,
        EllisDistribution, MeltsZirconDistribution, MeltsVolcanicZirconDistribution

end # module
