Auth = exports.plouffe_lib:Get("Auth")

Server = {
	WebHook = "",
	LogWebHook = "",
	Init = false,
	ChoppedCars = {}
}

Chop = {}
ChopFnc = {} 

Chop.Player = {}

Chop.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0) 
}

Chop.Shops = {
	vagosAutoShop = {
		name = "vagosAutoShop",
		isZone = true,
		coords = {
			vector3(470.21096801758, -1887.9229736328, 26.09733581543),
			vector3(468.87582397461, -1885.4591064453, 26.100402832031),
			vector3(463.24237060547, -1888.1953125, 26.100402832031),
			vector3(461.24481201172, -1883.9755859375, 26.100402832031),
			vector3(475.60443115234, -1877.1630859375, 26.100402832031),
			vector3(476.85064697266, -1879.1593017578, 26.100402832031),
			vector3(479.63302612305, -1877.9451904297, 26.100402832031),
			vector3(481.90704345703, -1882.9149169922, 26.100402832031)
		},
		maxZ = 29,
		minZ = 22,
		label = "Démonter le véhicule",
		keyMap = {
			event = "plouffe_chopshop:chopstuff",
			key = "M"
		}
	},

	scrapYardDelaroulotte = {
		name = "scrapYardDelaroulotte",
		coords = vector3(-525.94940185547, -1724.3500976563, 19.21794128418),
		distance = 8.0,
		isZone = true,
		label = "Envoyer le véhicule a la scrap",
		keyMap = {
			event = "plouffe_chopshop:scrapyard",
			key = "E"
		}
	}
}

Chop.Parts = {
	{
		boneName = "chassis_dummy",
		side = "body_chassis",
		maxDst = 3.5,
	},
	{
		boneName = "engine",
		side = "body_engine",
		maxDst = 2.0,
	},
	{
		boneName = "bonnet", 
		partId = 4,
		side = "door_hood",
		maxDst = 2.0,
	},
	{
		boneName = "boot", 
		partId = 5,
		side = "door_rear",
		maxDst = 1.5,
	},
	{
		boneName = "door_dside_f",
		partId = 0,
		side = "door_front_left",
		maxDst = 1.2,
	},
	{
		boneName = "door_dside_r",
		partId = 2,
		side = "door_rear_left",
		maxDst = 1.2,
	},
	{
		boneName = "door_pside_f",
		partId = 1,
		side = "door_front_right",
		maxDst = 1.2,
	},
	{
		boneName = "door_pside_r",
		partId = 3,
		side = "door_rear_right",
		maxDst = 1.2,
	},
	{
		boneName = "wheel_lf",
		partId = 0,
		side = "wheel_front_left",
		maxDst = 1.2,
	},
	{
		boneName = "wheel_lr",
		partId = 4,
		side = "wheel_rear_left",
		maxDst = 1.2,
	},
	{
		boneName = "wheel_rf",
		partId = 1,
		side = "wheel_front_right",
		maxDst = 1.2,
	},
	{
		boneName = "wheel_rr",
		partId = 5,
		side = "wheel_rear_right",
		maxDst = 1.2,
	}
}

Chop.Rewards = {
	engine = {
		{item = "engineparts", amount = 1},
		{item = "transmissionparts", amount = 1}
	},
	chassis_dummy = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	bonnet = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	boot = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	door_dside_f = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	door_dside_r = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	door_pside_f = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	door_pside_r = {
		{item = "steel", amount = 7},
		{item = "plastic", amount = 7}
	},
	wheel_lf = {
		{item = "brakesparts", amount = 1},
		{item = "suspensionparts", amount = 1},
		{item = "tiresparts", amount = 1}
	},
	wheel_lr = {
		{item = "brakesparts", amount = 1},
		{item = "suspensionparts", amount = 1},
		{item = "tiresparts", amount = 1}
	},
	wheel_rf = {
		{item = "brakesparts", amount = 1},
		{item = "suspensionparts", amount = 1},
		{item = "tiresparts", amount = 1}
	},
	wheel_rr = {
		{item = "brakesparts", amount = 1},
		{item = "suspensionparts", amount = 1},
		{item = "tiresparts", amount = 1}
	},
	car = {
		{item = "steel", amount = 15},
		{item = "plastic", amount = 15},
		{item = "money", amount = math.random(25,100)},
	}
}

Chop.TowTruck = {
	{model = GetHashKey("flatbed"), offSet = vector3(0,-10,0)}
}

Chop.Menu = {
	refab = {
		{
			id = 1,
			header = "Carosserie",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "bodyparts"
				}
			}
		},
		{
			id = 2,
			header = "Freins",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "brakesparts"
				}
			}
		},
		{
			id = 3,
			header = "Clutch",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "clutchparts"
				}
			}
		},
		{
			id = 4,
			header = "Radiateur",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "coolingparts"
				}
			}
		},
		{
			id = 5,
			header = "Electroniques",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "electronicparts"
				}
			}
		},
		{
			id = 6,
			header = "Moteur",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "engineparts"
				}
			}
		},
		{
			id = 7,
			header = "Injecteurs",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "injectorparts"
				}
			}
		},
		{
			id = 8,
			header = "Suspension",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "suspensionparts"
				}
			}
		},
		{
			id = 9,
			header = "Pneu",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "tiresparts"
				}
			}
		},
		{
			id = 10,
			header = "Transmission",
			txt = "Echanger 5 pieces pour 1 de meilleur qualiter",
			params = {
				event = "",
				args = {
					type = "transmissionparts"
				}
			}
		}
	},
	types = {
		{
			id = 1,
			header = "A",
			txt = "Echanger 5 A pour 1 S",
			params = {
				event = "",
				args = {
					type = "a"
				}
			}
		},
		{
			id = 2,
			header = "B",
			txt = "Echanger 5 B pour 1 A",
			params = {
				event = "",
				args = {
					type = "b"
				}
			}
		},
		{
			id = 3,
			header = "C",
			txt = "Echanger 5 C pour 1 B",
			params = {
				event = "",
				args = {
					type = "c"
				}
			}
		},
		{
			id = 4,
			header = "D",
			txt = "Echanger 5 D pour 1 C",
			params = {
				event = "",
				args = {
					type = "d"
				}
			}
		}
	}
}

Chop.RefabClass = {
	a = "s",
	b = "a",
	c = "b",
	d = "c"
}