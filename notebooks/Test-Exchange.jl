### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 029fefe6-56bf-4e5c-9198-7a2bb8a00889
begin
	using Parameters
end

# ╔═╡ 9827859f-ffd9-4c55-abd8-7969dcaa90c9
number_of_iterations = 1

# ╔═╡ 317bfe52-fc27-4c2c-a58f-a7b55ce1973f
number_of_agents = 10

# ╔═╡ 4ed1ab97-435d-4928-8a36-f93916a89c28
number_of_assets = 10

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
	
	# return -
	nothing 
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
	
		# grab -
		push!(my_agent_array, agent_model)
	end
	
	# attach the agents to the world -
	game_world.agent_array = my_agent_array
	
	# return -
	nothing
end

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

[compat]
Parameters = "~0.12.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"
"""

# ╔═╡ Cell order:
# ╠═029fefe6-56bf-4e5c-9198-7a2bb8a00889
# ╠═9827859f-ffd9-4c55-abd8-7969dcaa90c9
# ╠═317bfe52-fc27-4c2c-a58f-a7b55ce1973f
# ╠═4ed1ab97-435d-4928-8a36-f93916a89c28
# ╠═76280c54-afd3-4655-a991-54b957de8b5f
# ╠═df0780f6-2854-11ec-21a7-8b1cd061e361
# ╟─0f860b70-7f65-4d04-a27d-088e752c496f
# ╟─ce1ba111-1cba-4c4a-945e-104f3b8acee0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
