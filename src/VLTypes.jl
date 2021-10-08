abstract type VLAbstractAgentModel end
abstract type VLAbstractGameWorld end
abstract type VLAbstractOrderModel end

# setup agent type -
mutable struct VLAgentModel <: VLAbstractAgentModel

    # agent data -
    agent_id::UUID
    agent_position_array::Array{Int64,2}
    agent_wealth_array::Array{Float64,1}
    agent_trade_logic::Function
    agent_update_logic::Function

    # default inner constructor -
    VLAgentModel() = new()
end

mutable struct VLGameWorld <: VLAbstractGameWorld

    # game world data -
    asset_price_array::Array{Float64,2}
    agent_array::Array{VLAgentModel,1}
    number_of_iterations::Int64
    exchange_logic::Function

    # default inner constructor
    VLGameWorld() = new()
end

struct VLOrderModel <: VLAbstractOrderModel
end

struct VLMarketSimulationResult
    agent_array::Array{VLAgentModel,1}
    asset_price_array::Array{Float64,2}
end