using Mimi
include("utils/load_parameters.jl")
include("components/CO2emissions.jl")
include("components/CO2cycle.jl")
include("components/CO2forcing.jl")
include("components/CH4emissions.jl")
include("components/CH4cycle.jl")
include("components/CH4forcing.jl")
include("components/N2Oemissions.jl")
include("components/N2Ocycle.jl")
include("components/N2Oforcing.jl")
include("components/LGemissions.jl")
include("components/LGcycle.jl")
include("components/LGforcing.jl")
include("components/SulphateForcing.jl")
include("components/TotalForcing.jl")
include("components/ClimateTemperature.jl")
include("components/SeaLevelRise.jl")
include("components/GDP.jl")
include("components/MarketDamages.jl")
include("components/NonMarketDamages.jl")
include("components/Discontinuity.jl")
include("components/AdaptationCosts.jl")
include("components/SLRDamages.jl")
include("components/AbatementCostParameters.jl")
include("components/AbatementCosts.jl")
include("components/TotalAbatementCosts.jl")
include("components/TotalAdaptationCosts.jl")
include("components/Population.jl")
include("components/EquityWeighting.jl")

function buildpage(m::Model, policy::String="policy-a")
    #add all the components
    CO2emissions = addcomponent(m,co2emissions)
    CO2cycle = addCO2cycle(m)
    CO2forcing = addCO2forcing(m)
    CH4emissions = addcomponent(m, ch4emissions)
    CH4cycle = addCH4cycle(m)
    CH4forcing = addCH4forcing(m)
    N2Oemissions = addcomponent(m, n2oemissions)
    N2Ocycle = addN2Ocycle(m)
    N2Oforcing = addN2Oforcing(m)
    lgemissions = addcomponent(m, LGemissions)
    lgcycle = addLGcycle(m)
    lgforcing = addLGforcing(m)
    sulphateforcing = addsulphatecomp(m)
    totalforcing = addcomponent(m, TotalForcing)
    climatetemperature = addclimatetemperature(m)
    sealevelrise = addSLR(m)
    #Socio-Economics
    population = addpopulation(m)
    gdp = addgdp(m)
    #Abatement Costs
    abatementcostparameters_CO2 = addabatementcostparameters(m, :CO2, policy)
    abatementcostparameters_CH4 = addabatementcostparameters(m, :CH4, policy)
    abatementcostparameters_N2O = addabatementcostparameters(m, :N2O, policy)
    abatementcostparameters_Lin = addabatementcostparameters(m, :Lin, policy)
    abatementcosts_CO2 = addabatementcosts(m, :CO2, policy)
    abatementcosts_CH4 = addabatementcosts(m, :CH4, policy)
    abatementcosts_N2O = addabatementcosts(m, :N2O, policy)
    abatementcosts_Lin = addabatementcosts(m, :Lin, policy)
    totalabatementcosts = addtotalabatementcosts(m)
    #Adaptation Costs
    adaptationcosts_sealevel = addadaptationcosts_sealevel(m)
    adaptationcosts_economic = addadaptationcosts_economic(m)
    adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
    totaladaptationcosts = addtotaladaptationcosts(m)
    # Impacts
    slrdamages = addslrdamages(m)
    marketdamages = addmarketdamages(m)
    nonmarketdamages= addnonmarketdamages(m)
    discontinuity= adddiscontinuity(m)
    #Equity weighting and Total Costs
    equityweighting=addequityweighting(m)

    #connect parameters together
    CO2cycle[:e_globalCO2emissions] = CO2emissions[:e_globalCO2emissions]
    CO2cycle[:rt_g0_baseglobaltemp] = climatetemperature[:rt_g0_baseglobaltemp]
    CO2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

    CO2forcing[:c_CO2concentration] = CO2cycle[:c_CO2concentration]

    CH4cycle[:e_globalCH4emissions] = CH4emissions[:e_globalCH4emissions]
    CH4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
    CH4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

    CH4forcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
    CH4forcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

    N2Ocycle[:e_globalN2Oemissions] = N2Oemissions[:e_globalN2Oemissions]
    N2Ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
    N2Ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

    N2Oforcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
    N2Oforcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

    lgcycle[:e_globalLGemissions] = lgemissions[:e_globalLGemissions]
    lgcycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
    lgcycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

    lgforcing[:c_LGconcentration] = lgcycle[:c_LGconcentration]

    totalforcing[:f_CO2forcing] = CO2forcing[:f_CO2forcing]
    totalforcing[:f_CH4forcing] = CH4forcing[:f_CH4forcing]
    totalforcing[:f_N2Oforcing] = N2Oforcing[:f_N2Oforcing]
    totalforcing[:f_lineargasforcing] = lgforcing[:f_LGforcing]

    climatetemperature[:ft_totalforcing] = totalforcing[:ft_totalforcing]
    climatetemperature[:fs_sulfateforcing] = sulphateforcing[:fs_sulphateforcing]

    sealevelrise[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

    gdp[:pop_population] = population[:pop_population]

    for allabatement in [(abatementcostparameters_CO2, abatementcosts_CO2),
                         (abatementcostparameters_CH4, abatementcosts_CH4),
                         (abatementcostparameters_N2O, abatementcosts_N2O),
                         (abatementcostparameters_Lin, abatementcosts_Lin)]
        abatementcostparameters, abatementcosts = allabatement

        abatementcostparameters[:yagg] = gdp[:yagg_periodspan]
        abatementcostparameters[:cbe_absoluteemissionreductions] = abatementcosts[:cbe_absoluteemissionreductions]

        abatementcosts[:zc_zerocostemissions] = abatementcostparameters[:zc_zerocostemissions]
        abatementcosts[:q0_absolutecutbacksatnegativecost] = abatementcostparameters[:q0_absolutecutbacksatnegativecost]
        abatementcosts[:blo] = abatementcostparameters[:blo]
        abatementcosts[:alo] = abatementcostparameters[:alo]
        abatementcosts[:bhi] = abatementcostparameters[:bhi]
        abatementcosts[:ahi] = abatementcostparameters[:ahi]
    end

    totalabatementcosts[:tc_totalcosts_co2] = abatementcosts_CO2[:tc_totalcost]
    totalabatementcosts[:tc_totalcosts_n2o] = abatementcosts_N2O[:tc_totalcost]
    totalabatementcosts[:tc_totalcosts_ch4] = abatementcosts_CH4[:tc_totalcost]
    totalabatementcosts[:tc_totalcosts_linear] = abatementcosts_Lin[:tc_totalcost]
    totalabatementcosts[:pop_population] = population[:pop_population]

    adaptationcosts_economic[:gdp] = gdp[:gdp]
    adaptationcosts_noneconomic[:gdp] = gdp[:gdp]
    adaptationcosts_sealevel[:gdp] = gdp[:gdp]

    totaladaptationcosts[:ac_adaptationcosts_economic] = adaptationcosts_economic[:ac_adaptivecosts]
    totaladaptationcosts[:ac_adaptationcosts_noneconomic] = adaptationcosts_noneconomic[:ac_adaptivecosts]
    totaladaptationcosts[:ac_adaptationcosts_sealevelrise] = adaptationcosts_sealevel[:ac_adaptivecosts]
    totaladaptationcosts[:pop_population] = population[:pop_population]

    slrdamages[:s_sealevel] = sealevelrise[:s_sealevel]
    slrdamages[:cons_percap_consumption] = gdp[:cons_percap_consumption]
    slrdamages[:tct_per_cap_totalcostspercap] = totalabatementcosts[:tct_per_cap_totalcostspercap]
    slrdamages[:act_percap_adaptationcosts] = totaladaptationcosts[:act_percap_adaptationcosts]
    connectparameter(m, :SLRDamages, :atl_adjustedtolerablelevelofsealevelrise, :AdaptiveCostsSeaLevel, :atl_adjustedtolerablelevel, ignoreunits=true)
    slrdamages[:imp_actualreductionSLR] = adaptationcosts_sealevel[:imp_adaptedimpacts]
    slrdamages[:isatg_impactfxnsaturation] = gdp[:isatg_impactfxnsaturation]

    marketdamages[:rtl_realizedtemperature] = climatetemperature[:rtl_realizedtemperature]
    marketdamages[:rgdp_per_cap_SLRRemainGDP] = slrdamages[:rgdp_per_cap_SLRRemainGDP]
    marketdamages[:rcons_per_cap_SLRRemainConsumption] = slrdamages[:rcons_per_cap_SLRRemainConsumption]
    connectparameter(m, :MarketDamages, :atl_adjustedtolerableleveloftemprise, :AdaptiveCostsEconomic, :atl_adjustedtolerablelevel, ignoreunits=true)
    marketdamages[:imp_actualreduction] = adaptationcosts_economic[:imp_adaptedimpacts]
    marketdamages[:isatg_impactfxnsaturation] = gdp[:isatg_impactfxnsaturation]

    nonmarketdamages[:rtl_realizedtemperature] = climatetemperature[:rtl_realizedtemperature]
    nonmarketdamages[:rgdp_per_cap_MarketRemainGDP] = marketdamages[:rgdp_per_cap_MarketRemainGDP]
    nonmarketdamages[:rcons_per_cap_MarketRemainConsumption] = marketdamages[:rcons_per_cap_MarketRemainConsumption]
    connectparameter(m, :NonMarketDamages, :atl_adjustedtolerableleveloftemprise, :AdaptiveCostsNonEconomic, :atl_adjustedtolerablelevel, ignoreunits=true)
    nonmarketdamages[:imp_actualreduction] = adaptationcosts_noneconomic[:imp_adaptedimpacts]
    nonmarketdamages[:isatg_impactfxnsaturation] = gdp[:isatg_impactfxnsaturation]

    discontinuity[:rgdp_per_cap_NonMarketRemainGDP] = nonmarketdamages[:rgdp_per_cap_NonMarketRemainGDP]
    discontinuity[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]
    discontinuity[:rgdp_per_cap_NonMarketRemainGDP] = nonmarketdamages[:rgdp_per_cap_NonMarketRemainGDP]
    discontinuity[:rcons_per_cap_NonMarketRemainConsumption] = nonmarketdamages[:rcons_per_cap_NonMarketRemainConsumption]
    discontinuity[:isatg_saturationmodification] = gdp[:isatg_impactfxnsaturation]

    equityweighting[:pop_population] = population[:pop_population]
    equityweighting[:tct_percap_totalcosts_total] = totalabatementcosts[:tct_per_cap_totalcostspercap]
    equityweighting[:act_adaptationcosts_total] = totaladaptationcosts[:act_adaptationcosts_total]
    equityweighting[:act_percap_adaptationcosts] = totaladaptationcosts[:act_percap_adaptationcosts]
    equityweighting[:cons_percap_consumption] = gdp[:cons_percap_consumption]
    equityweighting[:cons_percap_consumption_0] = gdp[:cons_percap_consumption_0]
    equityweighting[:cons_percap_aftercosts] = slrdamages[:cons_percap_aftercosts]
    equityweighting[:rcons_percap_dis] = discontinuity[:rcons_per_cap_DiscRemainConsumption]
    equityweighting[:yagg_periodspan] = gdp[:yagg_periodspan]

    return m
end

function initpage(m::Model, policy::String="policy-a")
    p = load_parameters(m, policy)
    p["y_year_0"] = 2008.
    p["y_year"] = m.indices_values[:time]
    setleftoverparameters(m, p)
end

function getpage(policy::String="policy-a")
    m = Model()
    setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

    buildpage(m, policy)

    # next: add vector and panel example
    initpage(m, policy)

    return m
end
