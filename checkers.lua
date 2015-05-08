-- CHECKERS GAME

local checkers ={};
checkers.piece = "";checkers.time = 0;
checkers.pos = {} -- bottom left position of 8x8 checkerboard piece
checkers.piece_pos = {} -- position of pick up piece

--game pieces

local function draw_board() -- pos is bottom left position of checkerboard
	
	local pos = checkers.pos;
	local node;
	for i = 1,8 do
		for j =1,8 do
			node = minetest.get_node({x=pos.x+i-1,y=pos.y,z=pos.z-1}).name;
			if (i+j) % 2 == 1 then 
				if node~="games:board_black" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z+j-1},{name = "games:board_black"}) end
				else
				if node~="games:board_white" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z+j-1},{name = "games:board_white"}) end
			end
			node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+j-1}).name;
			if node~="air" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+j-1},{name = "air"}) end
		end
	end

	for i = 1,4 do -- place pieces
		minetest.set_node({x=pos.x+2*i-1,y=pos.y+1,z=pos.z},{name = "games:checkers_red"})
		minetest.set_node({x=pos.x+2*i-2,y=pos.y+1,z=pos.z+1},{name = "games:checkers_red"})
		
		minetest.set_node({x=pos.x+2*i-1,y=pos.y+1,z=pos.z+6},{name = "games:checkers_blue"})
		minetest.set_node({x=pos.x+2*i-2,y=pos.y+1,z=pos.z+7},{name = "games:checkers_blue"})
	end
	
	for i = 1,8 do -- place kings
		node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z-2}).name;
		if node~="games:checkers_red_queen" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z-2},{name = "games:checkers_red_queen"}) end
		node = minetest.get_node({x=pos.x+i-1,y=pos.y,z=pos.z-2}).name;
		if node~="games:board_white" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z-2},{name = "games:board_white"}) end
		
		node = minetest.get_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+9}).name;
		if node~="games:checkers_blue_queen" then minetest.set_node({x=pos.x+i-1,y=pos.y+1,z=pos.z+9},{name = "games:checkers_blue_queen"}) end
		node = minetest.get_node({x=pos.x+i-1,y=pos.y,z=pos.z+9}).name;
		if node~="games:board_white" then minetest.set_node({x=pos.x+i-1,y=pos.y,z=pos.z+9},{name = "games:board_white"}) end

	end
	
end

minetest.register_node("games:checkers", {
description = "checkers crate",
	tiles = {"moreblocks_iron_checker.png","crate.png","crate.png","crate.png","crate.png","crate.png"},
	groups = {oddly_breakable_by_hand=1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 14,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext","checkers game block, admin only")
		meta:set_int("time", minetest.get_gametime());
		checkers.pos = {x = pos.x+1, y=pos.y-1, z=pos.z+1}
	end, 
	on_punch = function(pos, node, player)
		local name = player:get_player_name(); if name==nil then return end
		local privs = minetest.get_player_privs(name); 
		if not privs.kick then return end -- only admin
		checkers.pos = {x = pos.x+1, y=pos.y, z=pos.z+1}
		draw_board()
	end
	}
	)


minetest.register_chatcommand("checkers", {
    description = "Start a game of checkers and refresh board display",
    privs = {kick=true},
    func = function(name,param)
		draw_board();checkers.piece = ""
	end
	}
)


function register_piece(name, desc, tiles, punch)
	minetest.register_node(name, {
		description = desc,
		drawtype = "nodebox",
		paramtype = "light",
		tiles = tiles,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3},
		sounds = default.node_sound_defaults(),
		node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
					
		},
		on_punch= punch,
	}) 
end
function register_board(name,desc,tiles)
	minetest.register_node(name, {
			description = desc,
			tiles = tiles,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3},
			sounds = default.node_sound_defaults(),
			on_punch = function(pos, node, player) -- place piece on board
					local name = player:get_player_name(); if name == nil then return end
					if checkers.pos.x == nil then minetest.chat_send_player(name,"punch checkers game block before playing.") return end
					if checkers.piece == "" then return end
					local t = minetest.get_gametime(); if t-checkers.time <1 then return end; checkers.time = t;
					local above = {x=pos.x,y=pos.y+1;z=pos.z};
					local x,y; x= above.z-checkers.pos.z+1; y=above.x-checkers.pos.x+1;
					minetest.set_node(above, {name = checkers.piece});
					
					minetest.chat_send_all(
					"#CHECKERS : " .. name .." moved: ".. checkers.piece_pos.z-checkers.pos.z+1 .. "," .. checkers.piece_pos.x-checkers.pos.x+1 .. " to " ..
					x .. "," .. y )
					checkers.piece = ""
			end,
			on_rightclick = function(pos, node, player, itemstack, pointed_thing) -- capture piece 
				local name = player:get_player_name(); if name == nil then return end
					if checkers.pos.x == nil then minetest.chat_send_player(name,"punch checkers game block before playing.") return end
					if checkers.piece == "" then return end
					minetest.chat_send_all(name .." captured piece at ".. checkers.piece_pos.z-checkers.pos.z+1 .. ","..checkers.piece_pos.x-checkers.pos.x+1)
					checkers.piece = "" return 
			end
			
	}) 
end

local piece_punch  = function(pos, node, player) -- pick up piece
	local name = player:get_player_name(); if name == nil then return end
	if checkers.pos.x == nil then minetest.chat_send_player(name,"punch checkers game block before playing (need kick priv).") return end
	if checkers.piece~="" then return end -- dont pick up another piece before last one was put down
	
	local t = minetest.get_gametime(); if t-checkers.time <1 then return end; checkers.time = t;
	checkers.piece = node.name; minetest.set_node(pos, {name="air"});
	checkers.piece_pos = {x=pos.x,y=pos.y,z=pos.z};
end

register_board("games:board_white","white board",{"wool_white.png"})
register_board("games:board_black","black board",{"wool_black.png"})

register_piece("games:checkers_blue","blue piece",{"wool_blue.png"},piece_punch)
register_piece("games:checkers_blue_queen","blue queen piece",{"queen_blue.png"},piece_punch)

register_piece("games:checkers_red","red piece",{"wool_red.png"},piece_punch)
register_piece("games:checkers_red_queen","red piece",{"queen_red.png"},piece_punch)