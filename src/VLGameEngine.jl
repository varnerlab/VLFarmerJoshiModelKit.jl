function run(world::VLGameWorld)::VLMarketSimulationResult

    try

        # get data about the world -
        agent_array = world.agent_array                                         # get the agent array 
        asset_price_array = world.asset_price_array                             # get the asset price array
        number_of_iterations = world.number_of_iterations                       # how iterations are we going to do -
        number_of_agents = length(agent_array)
        (number_of_iterations, number_of_assets) = size(asset_price_array)
        
        # initialize simulation data structures -
        agent_desired_orders_array = Array{VLOrderModel,2}(undef, number_of_agents, number_of_assets)

        # main game loop -
        for iteration_index = 1:number_of_iterations
            
            # for each agent, we need to pass the current price array to the logic function -
            for agent_index = 1:number_of_agents
                
                # get the agent model -
                agent_model = agent_array[agent_index]
            
                # what is the desired position size in the next time step?
                # desired_position_size_array: number of assets x 1 array 
                tmp_desired_order_array = agent_model.agent_trade_logic(agent_model, asset_price_array)
                for asset_index = 1:number_of_assets
                    agent_desired_orders_array[agent_index, asset_index] =  tmp_desired_order_array[asset_index]
                end
            end

            # ok, so let's post the desired trades to the exchange -> and get the exachange output 
            asset_price_array = world.exchange_logic(iteration_index, world, agent_desired_orders_array, asset_price_array)
            
            # update the agents -
            for agent_index = 1:number_of_agents

                # update the agent -
                agent_model = agent_array[agent_index]

                # call the update function -
                agent_model.agent_update_logic(iteration_index, agent_model)
            end
        end

        # build result object -
        result_object = VLMarketSimulationResult(agent_array, asset_price_array)

        # return -
        return result_object
    catch error
        rethrow(error)
    end
end