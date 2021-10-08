abstract type VLAbstractAgentModel end
abstract type VLAbstractGameWorld end
abstract type VLAbstractOrderModel end

# what actions are we going to take?
@enum Action BUY SELL HOLD
𝒜 = [BUY::Action = 1, SELL::Action = -1, HOLD::Action = 0]

# what are the different types of orders?
@enum Order CANCEL MARKET LIMIT
𝒪 = [CANCEL::Order = 0, MARKET::Order = 1, LIMIT::Order = 2]

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
    liquidity_parameter_array::Array{Float64,1}
    agent_array::Array{VLAgentModel,1}
    number_of_iterations::Int64
    exchange_logic::Function

    # default inner constructor
    VLGameWorld() = new()
end

struct VLOrderModel <: VLAbstractOrderModel

    # data -
    asset_index::Int64
    action::Action
    order::Order
    quantity::Int64
    price::Float64
    agent_id::UUID
    order_id::UUID
end

struct VLMarketSimulationResult
    asset_price_array::Array{Float64,2}

    # constructor -
    VLMarketSimulationResult(array::Array{Float64,2}) = new(array)
end