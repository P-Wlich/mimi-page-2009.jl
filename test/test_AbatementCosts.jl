using Mimi
using DataFrames
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/AbatementCostParameters.jl")
include("../src/components/AbatementCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

for gas in [:CO2, :CH4, :N2O, :Lin]
    abatementcostparameters = addabatementcostparameters(m, gas)
    abatementcosts = addabatementcosts(m, gas)

    abatementcostparameters[:yagg] = readpagedata(m,"test/validationdata/yagg_periodspan.csv")
    abatementcostparameters[:cbe_absoluteemissionreductions] = abatementcosts[:cbe_absoluteemissionreductions]
        
    abatementcosts[:zc_zerocostemissions] = abatementcostparameters[:zc_zerocostemissions]
    abatementcosts[:q0_absolutecutbacksatnegativecost] = abatementcostparameters[:q0_absolutecutbacksatnegativecost]
    abatementcosts[:blo] = abatementcostparameters[:blo]
    abatementcosts[:alo] = abatementcostparameters[:alo]
    abatementcosts[:bhi] = abatementcostparameters[:bhi]
    abatementcosts[:ahi] = abatementcostparameters[:ahi]
end

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)

@test !isnan(m[:AbatementCostsCO2, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsCH4, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsN2O, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsLin, :tc_totalcost][10, 5])

#compare output to validation data
tc_compare_co2=readpagedata(m, "test/validationdata/tc_totalcosts_co2.csv")
tc_compare_ch4=readpagedata(m, "test/validationdata/tc_totalcosts_ch4.csv")
tc_compare_n2o=readpagedata(m, "test/validationdata/tc_totalcosts_n2o.csv")
tc_compare_lin=readpagedata(m, "test/validationdata/tc_totalcosts_linear.csv")

zc_compare_co2=readpagedata(m, "test/validationdata/zc_zerocostemissionsCO2.csv")
zc_compare_ch4=readpagedata(m, "test/validationdata/zc_zerocostemissionsCH4.csv")
zc_compare_n2o=readpagedata(m, "test/validationdata/zc_zerocostemissionsN2O.csv")
zc_compare_lin=readpagedata(m, "test/validationdata/zc_zerocostemissionsLG.csv")


@test m[:AbatementCostsCO2, :tc_totalcost] ≈ tc_compare_co2 rtol=1e-2
@test m[:AbatementCostsCH4, :tc_totalcost] ≈ tc_compare_ch4 rtol=1e-2
@test m[:AbatementCostsN2O, :tc_totalcost] ≈ tc_compare_n2o rtol=1e-2
@test m[:AbatementCostsLin, :tc_totalcost] ≈ tc_compare_lin rtol=1e-2

@test m[:AbatementCostParametersCO2, :zc_zerocostemissions] ≈ zc_compare_co2 rtol=1e-2
@test m[:AbatementCostParametersCH4, :zc_zerocostemissions] ≈ zc_compare_ch4 rtol=1e-3
@test m[:AbatementCostParametersN2O, :zc_zerocostemissions] ≈ zc_compare_n2o rtol=1e-3
@test m[:AbatementCostParametersLin, :zc_zerocostemissions] ≈ zc_compare_lin rtol=1e-3
