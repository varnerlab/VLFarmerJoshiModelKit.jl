abstract type VLAbstractAgentModel end
abstract type VLAbstractGameWorld end
abstract type VLAbstractOrderModel end

# setup enum for actions and orders -
@enum ActionType BUY = 1 SELL = -1 HOLD = 0       # what actions are we going to take?
@enum OrderType CANCEL = 0 MARKET = 1 LIMIT = 2   # what are the different types of orders?

# setup agent type -
mutable struct VLAgentModel <: VLAbstractAgentModel

    # agent data -
    agent_id::UUID
    agent_position_array::Array{Int64,2}
    agent_wealth_array::Array{Float64,1}
    agent_trade_logic::Function
    agent_update_logic::Function
    agent_parameters::Dict{String,Any}

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

    # constructor - 
    VLGameWorld() = new()
end

struct VLOrderModel <: VLAbstractOrderModel

    # data -
    asset_index::Int64
    action::Int64
    order_type::Int64
    quantity::Int64
    price::Float64
    agent_id::UUID
    order_id::UUID

    # constructor -
    VLOrderModel(asset_index, action, order_type, quantity, price, agent_id) = new(asset_index, action, order_type, 
        quantity, price, agent_id, uuid4())
end

struct VLMarketSimulationResult
    
    agent_array::Array{VLAgentModel,1}
    asset_price_array::Array{Float64,2}


    # constructor -
    VLMarketSimulationResult(agents, price_array) = new(agents, price_array)
end