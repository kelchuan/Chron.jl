# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                            Chron1.0DistOnly.jl                                #
#                                                                               #
#     Illustrates the use of the Chron.jl package to estimate eruption          #
#  and/or deposition ages.                                                      #
#                                                                               #
#     This file uses code cells (denoted by "## ---"). To evaluate a cell in    #
#  the Julia REPL and move to the next cell, the default shortcut in Atom is    #
#  alt-shift-enter.                                                             #
#                                                                               #
#     You may have to adjust the path below which specifies the location of     #
#  the CSV data files for each sample, depending on what you want to run.       #
#                                                                               #
#   Last modified by C. Brenhin Keller 2020-05-25                               #
#                                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## --- Load the Chron package - - - - - - - - - - - - - - - - - - - - - - - - -

    try
        using Chron
    catch
        using Pkg
        Pkg.add(PackageSpec(url="https://github.com/brenhinkeller/Chron.jl"))
        using Chron
    end

    using Statistics, StatsBase, DelimitedFiles, SpecialFunctions
    using Plots; gr();

## --- Define sample properties - - - - - - - - - - - - - - - - - - - - - - - -

    # This example data is from Clyde et al. (2016) "Direct high-precision
    # U–Pb geochronology of the end-Cretaceous extinction and calibration of
    # Paleocene astronomical timescales" EPSL 452, 272–280.
    # doi: 10.1016/j.epsl.2016.07.041

    nSamples = 5 # The number of samples you have data for
    smpl = NewChronAgeData(nSamples)
    smpl.Name      =  ("KJ08-157", "KJ04-75", "KJ09-66", "KJ04-72", "KJ04-70",)
    smpl.Height   .=  [     -52.0,      44.0,      54.0,      82.0,      93.0,]
    smpl.Height_sigma .= [    3.0,       1.0,       3.0,       3.0,       3.0,]
    smpl.Age_Sidedness .= zeros(nSamples) # Sidedness (zeros by default: geochron constraints are two-sided). Use -1 for a maximum age and +1 for a minimum age, 0 for two-sided
    smpl.Path = "examples/DenverUPbExampleData/" # Where are the data files?
    smpl.inputSigmaLevel = 2 # i.e., are the data files 1-sigma or 2-sigma. Integer.
    smpl.Age_Unit = "Ma" # Unit of measurement for ages and errors in the data files
    smpl.Height_Unit = "cm" # Unit of measurement for Height and Height_sigma

    # IMPORTANT: smpl.Height must increase with increasing stratigraphic height
    # -- i.e., stratigraphically younger samples must be more positive. For this
    # reason, it is convenient to represent depths below surface as negative
    # numbers.

    # For each sample in smpl.Name, we must have a csv file at smpl.Path which
    # contains each individual mineral age and uncertainty. For instance,
    # examples/DenverUPbExampleData/KJ08-157.csv contains:
    #
    #   66.12,0.14
    #   66.115,0.048
    #   66.11,0.1
    #   66.11,0.17
    #   66.096,0.056
    #   66.088,0.081
    #   66.085,0.076
    #   66.073,0.084
    #   66.07,0.11
    #   66.055,0.043
    #   66.05,0.16
    #   65.97,0.12


## --- Bootstrap pre-eruptive distribution - - - - - - - - - - - - - - - - - - -

    # Bootstrap a KDE of the pre-eruptive (or pre-deposition) zircon distribution
    # shape from individual sample datafiles using a KDE of stacked sample data
    BootstrappedDistribution = BootstrapCrystDistributionKDE(smpl)
    h = plot(range(0,1,length=length(BootstrappedDistribution)), BootstrappedDistribution,
        label="Bootstrapped distribution", xlabel="Time (arbitrary units)", ylabel="Probability Density",
        fg_color_legend=:white)
    savefig(h, joinpath(smpl.Path,"BootstrappedDistribution.pdf"))
    display(h)
## --- Estimate the eruption age distributions for each sample  - - - - - - - -

    # Configure distribution model here
    distSteps = 5*10^5 # Number of steps to run in distribution MCMC
    distBurnin = floor(Int,distSteps/2) # Number to discard

    # Choose the form of the prior distribution to use
    # Some pre-defined possiblilities include UniformDisribution,
    # TriangularDistribution, and MeltsVolcanicZirconDistribution
    # or you can define your own as with BootstrappedDistribution above
    dist = BootstrappedDistribution

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Run MCMC to estimate saturation and eruption/deposition age distributions
    @time tMinDistMetropolis(smpl,distSteps,distBurnin,dist)

    # This will save rank-order and distribution plots, and print results to a
    # csv file -- you can find them in smpl.Path


## ---
