function _default_exchange_logic!(iteration_index::Int64, game_world::VLGameWorld, 
    order_array::Array{VLOrderModel,1}, current_asset_price_array::Array{Float64,2})::Array{Float64,2}

    try

        # initialize -
        agent_array = game_world.agent_array
        number_of_assets = size(current_asset_price_array, 2)
        λ = game_world.liquidity_parameter_array
        number_of_orders = length(order_array)
        order_book = zeros(Int64, number_of_assets, number_of_orders)

        # build agent table -
        agent_table = Dict{UUID,VLAgentModel}()
        for agent in agent_array
            agent_id = agent.agent_id
            agent_table[agent_id] = agent
        end

        # build order lookup table -
        order_agent_lookup_table = Dict{UUID,VLAgentModel}()
        for order in order_array
            
            # get info about the order -
            order_id = order.order_id           # get the order id -
            agent_id = order.agent_id           # get the id of the agent who entered this order -
            agent_model = agent_table[agent_id] # get the model for the agent who entered this order -
            
            # link the order_id and the agent model -
            order_agent_lookup_table[order_id] = agent_model
        end

        # let process the orders - first, build the order book 
        for order_index = 1:number_of_orders
            
            # grab the order -
            order_model = order_array[order_index]
            asset_index = order_model.asset_index   # what asset index is this order?
            order_quantity = order_model.quantity   # what is the order quantity?
            order_action = order_model.action       # what is the order action?

            # add order to the order book for this asset -
            if (order_action == 1)
                order_book[asset_index, order_index] = order_quantity
            elseif (order_action == -1)
                order_book[asset_index, order_index] = -1 * order_quantity
            else
                order_book[asset_index, order_index] = 0
            end
        end


        # generate total order for each asset -
        total_order_quantity = sum(order_book, dims=2)

        # update the price for each asset -
        new_asset_price_array = copy(current_asset_price_array)
        for asset_index = 1:number_of_assets
            current_price = current_asset_price_array[iteration_index - 1, asset_index]
            new_asset_price_array[iteration_index, asset_index] = current_price + (1 / λ[asset_index]) * total_order_quantity[asset_index]
        end

        # default: assume all orders have been filled, update agents 
        for order_model in order_array
            
            order_id = order_model.order_id                         # get the order id -
            agent_model = order_agent_lookup_table[order_id]        # get the agent who made this order -
            
            # update -
            agent_model.agent_update_logic(agent_model, order_model, new_asset_price_array, iteration_index)
        end

        return new_asset_price_array
    catch error
        throw(error)
    end
end