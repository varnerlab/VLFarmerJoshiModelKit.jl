### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ 029fefe6-56bf-4e5c-9198-7a2bb8a00889
begin
	using Parameters
	using UUIDs
	using PlutoUI
end

# ╔═╡ 9827859f-ffd9-4c55-abd8-7969dcaa90c9
number_of_iterations = 100

# ╔═╡ 317bfe52-fc27-4c2c-a58f-a7b55ce1973f
number_of_agents = 10

# ╔═╡ 4ed1ab97-435d-4928-8a36-f93916a89c28
number_of_assets = 10

# ╔═╡ 07de0609-6f9b-406d-9fbf-cdfeaacdd335


# ╔═╡ 8f4a5b5e-1319-4df1-8fa4-b8a1e3b2d327
uuid4()


# ╔═╡ 886205dc-3f0f-4b5c-928e-4030b3cfd812
A = rand(100,2)

# ╔═╡ 6f3c3296-69f0-441e-8d01-814dd996f143
size(A,2)

# ╔═╡ b71b93a7-8106-4207-917c-4c7f907de970
rand(1:number_of_assets,number_of_assets)

# ╔═╡ 59cea89b-d09f-46be-ac26-5ce6befebf7f
d = Dict("A"=>rand(10),"B"=>2)

# ╔═╡ 9f7c16e9-6cf4-4d95-9d6c-d0fd9e0ffd91
typeof(d)

# ╔═╡ 0f860b70-7f65-4d04-a27d-088e752c496f
function ingredients(path::String; module_name::Symbol = :model)
	
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	
	# JV change ... want to
	# name = Symbol(basename(path))
	name = module_name
	
	# original -
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ df0780f6-2854-11ec-21a7-8b1cd061e361
begin
	
	# load my code into module M -
	M = ingredients("../Include.jl"; module_name = :ABM)
	
	# alias my types that are declared -
	VLAgentModel = M.VLAgentModel
	VLGameWorld = M.VLGameWorld
	VLOrderModel = M.VLOrderModel
	ActionType = M.ActionType
	OrderType = M.OrderType
	
	# return -
	nothing 
end

# ╔═╡ 914359d9-bfeb-4ab3-8448-041a3f7444f7
function my_technical_agent_trade_logic(agent_model, asset_price_array, iteration_index)
	
	with_terminal() do
		println("$(asset_price_array)")
	end
	
	# initialize -
	order_model_array = Array{VLOrderModel,1}()
	agent_position_array = agent_model.agent_position_array
	
	# get the parameters from this agent -
	parameters_dict = agent_model.agent_parameters
	
	# get the c-parameter array -
	c_parameter_array = parameters_dict["c_parameter_array"]
	price_lag_array = parameters_dict["price_lag_array"]
	
	# compute the setpoint array -
	(number_of_iterations, number_of_assets) = size(asset_price_array)
	for asset_index = 1:number_of_assets
		
		# what is the lag?
		asset_lag_index = price_lag_array[asset_index]
	
		# what is the lagged price for this asset?
		price_setpoint_value = 1.0
		if (asset_lag_index<iteration_index)
			price_setpoint_value = asset_price_array[(iteration_index - asset_lag_index),asset_index]
		end
		
		# build the order model -
		c_value = c_parameter_array[asset_index]
		current_price = asset_price_array[asset_index]
		desired_position_size = c_value*sign(current_price - price_setpoint_value)
		Δω = agent_position_array[iteration_index,asset_index] - desired_position_size
		
		# build the order -
		# an order has this data -
		local_asset_index = asset_index
    	action = (Δω < 0) ? -1 : 1
    	order_type = 1
    	quantity = 1
    	price = current_price
    	agent_id = agent_model.agent_id
		order_model = VLOrderModel(local_asset_index,action,order_type,quantity,price,agent_id);	
		push!(order_model_array,order_model)
	end
	
	# return -
	return order_model_array
end

# ╔═╡ 76280c54-afd3-4655-a991-54b957de8b5f
begin
	
	# build the game world -
	game_world = M.build(VLGameWorld; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets);
	
	# build agent array -
	my_agent_array = Array{VLAgentModel,1}()
	for agent_index = 1:number_of_agents
		
		# let's use the defaults for the various agent settings -
		agent_model = M.build(VLAgentModel; number_of_iterations=number_of_iterations, number_of_assets=number_of_assets)
		
		# setup parameters for this agent -
		c_array = rand(1:number_of_assets,number_of_assets)
		lag_array = rand(1:10,number_of_assets)
		p = Dict("c_parameter_array"=>c_array,"price_lag_array"=>lag_array)
		agent_model.agent_parameters = p
		
		# let's have all my agents be technical traders -
		agent_model.agent_trade_logic = my_technical_agent_trade_logic
			
		# grab -
		push!(my_agent_array, agent_model)
	end
	
	# attach the agents to the world -
	game_world.agent_array = my_agent_array
	
	# return -
	nothing
end

# ╔═╡ 92dbc919-0f2a-4abd-8cac-191ca51c2e26
R = M.run(game_world)

# ╔═╡ 0ee60583-af5a-48dd-a5e0-7fd1311bafc7
instances(ActionType)

# ╔═╡ ce1ba111-1cba-4c4a-945e-104f3b8acee0
html"""
<style>
main {
    max-width: 1200px;
    margin: auto;
	width: 90%;
    font-family: "Roboto, monospace";
}

a {
    color: blue;
    text-decoration: none;
}

.H1 {
    padding: 0px 30px;
}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
Parameters = "~0.12.3"
PlutoUI = "~0.7.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "f19e978f81eca5fd7620650d7dbea58f825802ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.0"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═029fefe6-56bf-4e5c-9198-7a2bb8a00889
# ╠═9827859f-ffd9-4c55-abd8-7969dcaa90c9
# ╠═317bfe52-fc27-4c2c-a58f-a7b55ce1973f
# ╠═4ed1ab97-435d-4928-8a36-f93916a89c28
# ╠═76280c54-afd3-4655-a991-54b957de8b5f
# ╠═df0780f6-2854-11ec-21a7-8b1cd061e361
# ╠═92dbc919-0f2a-4abd-8cac-191ca51c2e26
# ╠═07de0609-6f9b-406d-9fbf-cdfeaacdd335
# ╠═914359d9-bfeb-4ab3-8448-041a3f7444f7
# ╠═0ee60583-af5a-48dd-a5e0-7fd1311bafc7
# ╠═8f4a5b5e-1319-4df1-8fa4-b8a1e3b2d327
# ╠═886205dc-3f0f-4b5c-928e-4030b3cfd812
# ╠═6f3c3296-69f0-441e-8d01-814dd996f143
# ╠═b71b93a7-8106-4207-917c-4c7f907de970
# ╠═59cea89b-d09f-46be-ac26-5ce6befebf7f
# ╠═9f7c16e9-6cf4-4d95-9d6c-d0fd9e0ffd91
# ╟─0f860b70-7f65-4d04-a27d-088e752c496f
# ╟─ce1ba111-1cba-4c4a-945e-104f3b8acee0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
