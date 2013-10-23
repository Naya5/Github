

--
-- Crafting Environment
--   by: Ken Cheung
--


local USED_LOCALIZATION_KEYS = {
"STAT_DAMAGEPERSECOND",
"STAT_HEALTHPERROUND",
"STAT_RANGE",
"STAT_RELOADTIME",
"STAT_CLIPSIZE",
"STAT_RATING",
"STAT_JUMPHEIGHT",
"STAT_RUNSPEED",
"STAT_HEALTH",
"STAT_SPEED",
"STAT_CONSTRAINTS",
"STAT_BOOST",
"STAT_REDUCE",
"STAT_MAXAMMO",
"STAT_SPLASHRADIUS",
"STAT_SPREAD",
"STAT_DAMAGEPERROUND",
}


require "string";
require "math";
require "table";
require "lib/lib_Items"
require "lib/lib_ItemSelection";
require "lib/lib_SinvironmentModel"
require "lib/lib_ToolTip"
require "lib/lib_Wallet";
require "lib/lib_ErrorDialog"
require "lib/lib_VisualSlotter";
require "lib/lib_ScriptedTutorial";
require "./crafting/CFT_ManufactureHelper";
require "./crafting/CFT_RecipeHelper";

require "lib/lib_RowScroller"
require "lib/lib_Button"
require "lib/lib_CheckBox"
require "lib/lib_RoundedPopupWindow"
require "lib/lib_NavWheel";
require "lib/lib_WebCache";


require "lib/lib_Slash"


-- CONSTANTS
local RECIPE_ENTRY_HEIGHT = 20
local WORKBENCH_ENTRY_HEIGHT = 80
local INPUT_MENU_ENTRY_HEIGHT = 28
local STATS_ENTRY_HEIGHT = 24
local COMPARE_ENTRY_HEIGHT = 16
local OUTPUT_ENTRY_HEIGHT = 100

local TOOLTIP_DELAY = 0.5

local SECONDSINHOUR = 3600;
local SECONDSINDAY = 86400;

local FRAME			= Component.GetFrame("main");
local RIGHT_WING	= Component.GetFrame("right_wing")
local LEFT_WING		= Component.GetFrame("left_wing")

local WB_PURCHASEPROMPT = Component.GetWidget("WB_PurchasePrompt");
local WB_PURCHASEPROMPT_BODY = WB_PURCHASEPROMPT:GetChild("body");
local WB_PURCHASEPROMPT_TEXT = WB_PURCHASEPROMPT_BODY:GetChild("text");
local WB_PURCHASEPROMPT_LAYOUT = WB_PURCHASEPROMPT_BODY:GetChild("layout");
local WB_PURCHASEPROMPT_CRYSTITE = WB_PURCHASEPROMPT_LAYOUT:GetChild("crystite");
local WB_PURCHASEPROMPT_CRYSTITE_FOCUS = WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus");
local WB_PURCHASEPROMPT_VIP = WB_PURCHASEPROMPT_LAYOUT:GetChild("vip");
local WB_PURCHASEPROMPT_VIP_FOCUS = WB_PURCHASEPROMPT_VIP:GetChild("focus");
local WB_PURCHASEPROMPT_REDBEAN = WB_PURCHASEPROMPT_LAYOUT:GetChild("redbean");
local WB_PURCHASEPROMPT_REDBEAN_FOCUS = WB_PURCHASEPROMPT_REDBEAN:GetChild("focus");
local WB_PURCHASEPROMPT_CANCEL = WB_PURCHASEPROMPT_BODY:GetChild("cancel");

local PURCHASE_WORKBENCHES = Component.GetWidget("purchase_workbenches");
local PURCHASE_WORKBENCHES_BTN = nil;

local PURCHASE_VIP = Component.GetWidget("purchase_VIP");
local PURCHASE_VIP_BTN = nil;
--local VIP_PERK_TIP = Component.GetWidget("VIP_perk_tip");

local BG_FRAME		= Component.GetFrame("bg_frame");
local CHAT_PANEL	= Component.GetWidget("CHAT_PANEL");

local POPUP_DIALOG	= Component.GetWidget("PopupDialog");
local POPUP_BACK	= POPUP_DIALOG:GetChild("back");
local POPUP_TITLE	= POPUP_DIALOG:GetChild("title");
local POPUP_GROUP	= POPUP_DIALOG:GetChild("scroll");
local POPUP_TEXT	= POPUP_DIALOG:GetChild("scroll_text");
local POPUP_CLOSE	= POPUP_DIALOG:GetChild("close");
local POPUP_ROW		= nil;
local POPUP_SCROLL	= nil;

local INPUTS		= {GROUP = Component.GetWidget("inputs") }

local INPUTS_MENU					= Component.GetWidget("inputs_menu");
local INPUT_MENU_TITLE				= INPUTS_MENU:GetChild("input_name");
local INPUT_MENU_LIST				= INPUTS_MENU:GetChild("list");
local INPUT_MENU_SCROLL_BAR			= INPUTS_MENU:GetChild("scroll_bar");
local INPUT_MENU_SELECTED_ITEM		= INPUTS_MENU:GetChild("selected_item");
local INPUT_MENU_SELECTED_BTN		= INPUTS_MENU:GetChild("select");
local INPUT_MENU_QUANTITY			= INPUTS_MENU:GetChild("quantity");
local INPUT_MENU_MAX_QUANTITY		= INPUTS_MENU:GetChild("max_quantity");
local INPUT_MENU_SELECTED_ITEM_BG	= INPUTS_MENU:GetChild("selected_item_bg");
local INPUT_MENU_QUANTITY_BG		= INPUTS_MENU:GetChild("quantity_bg");

local INPUT_AMOUNTSELECTOR	= Component.GetWidget("Input_AmountSelector"); 
local INPUT_AMT_BACK		= INPUT_AMOUNTSELECTOR:GetChild("back");
local INPUT_AMT_TITLE		= INPUT_AMOUNTSELECTOR:GetChild("title");
local INPUT_AMT_BODY		= INPUT_AMOUNTSELECTOR:GetChild("body");
local INPUT_AMT_ACCEPT		= INPUT_AMOUNTSELECTOR:GetChild("accept");
local INPUT_AMT_CANCEL		= INPUT_AMOUNTSELECTOR:GetChild("cancel");
local INPUT_AMT_LIST		= nil;
local INPUT_AMT_ENTRY		= nil;

local INPUT_ENTRIES	= {};

local RECIPES				= Component.GetWidget("recipes");
local RECIPE_LIST_GROUP		= RECIPES:GetChild("list_group");
local RECIPE_LIST			= RECIPE_LIST_GROUP:GetChild("recipe_list");
local RECIPES_SEARCH		= RECIPES:GetChild("search_bar");
local RECIPES_SEARCH_ICON	= RECIPES_SEARCH:GetChild("icon");
local RECIPES_EMPTYPROMPT	= RECIPES_SEARCH:GetChild("EmptyPrompt");
local RECIPES_RECIPEFILTER	= RECIPES_SEARCH:GetChild("RecipeFilter");
local RECIPES_SCROLL_BAR	= RECIPE_LIST_GROUP:GetChild("scroll_bar");
local REFINE_BUTTON			= RECIPES:GetChild("refine");
local BATTLEFRAME_BUTTON	= RECIPES:GetChild("battleframe");
local RESEARCH_BUTTON		= RECIPES:GetChild("research");

local ITEM_NAME_BG = Component.GetWidget("item_name_bg");
local ITEM_NAME = Component.GetWidget("item_name");

local WORKBENCHES = Component.GetWidget("workbench_slots");
local WORKB_LIST = WORKBENCHES:GetChild("slot_list");
local WORKB_SCROLL_BAR = WORKBENCHES:GetChild("scroll_bar");

local CRAFT_TIP = Component.GetWidget("craft_tip");

local COMPONENT_TIP = Component.GetWidget("component_tip");
local MANUFACTURE_BTN = Component.GetWidget("manufacture_btn");
local TRACK_BTN = Component.GetWidget("track_btn");
local TUTORIAL_BTN = Component.GetWidget("tutorial_btn");
local NUM_PARALLEL = Component.GetWidget("num_parallel");
local NUM_PARALLEL_TXT = NUM_PARALLEL:GetChild("text");
local NUM_PARALLEL_SLIDER = NUM_PARALLEL:GetChild("slider");

local OUTPUT = Component.GetWidget("output");
local OUTPUT_TEXT = OUTPUT:GetChild("text");
local OUTPUT_QUALITY = OUTPUT:GetChild("quality");
local OUTPUT_QUANTITY = OUTPUT:GetChild("quantity");

local DESCRIPTION = Component.GetWidget("description");
local DESCRIPTION_TEXT = DESCRIPTION:GetChild("text");
local DESCRIPTION_GROUP = DESCRIPTION:GetChild("group");
local DESCRIPTION_SCROLL = nil;
local DESC_ROW = nil;

local REQUIREMENT_LIST = Component.GetWidget("requirement_list");

local STATS = Component.GetWidget("stats");
local STATS_SCROLL = nil;

local COMPARE_GROUP = Component.GetWidget("compare_with");
local COMPARE_MENU = COMPARE_GROUP:GetChild("menu");
local COMPARE_MENU_LIST = COMPARE_MENU:GetChild("list");
local COMPARE_MENU_TEXT = COMPARE_GROUP:GetChild("text"):GetChild("compare_text");

local PREVIEW_TITLE = Component.GetWidget("preview_title");
local OUTPUT_PREVIEW = Component.GetWidget("output_preview");
local OUTPUT_PREVIEW_LIST = OUTPUT_PREVIEW:GetChild("list");
local OUTPUT_PREVIEW_SCROLLBAR = OUTPUT_PREVIEW:GetChild("scroll_bar");

local WALLET = Component.GetWidget("wallet");

local CRAFTING_TIME = Component.GetWidget("crafting_time");
local CRAFTING_TIME_TEXT = CRAFTING_TIME:GetChild("text");

local MOUSE_BLOCK = Component.GetWidget("mouse_block");

local SOUND_MOUSE_OVER = "Play_UI_Login_Keystroke"
local SOUND_KEYSTROKE	= "Play_UI_Login_Keystroke";
local OLD_BLUEPRINT_TYPE_ID = 1516;
local BLUEPRINT_TYPE_ID = 3340;
local BLUEPRINT_REFINE_ID = 77;
local BLUEPRINT_BUILD_ID = 1516;
local BLUEPRINT_RESEARCH_ID = 87;

local COMP_QUALITY = ""
local COMP_POWER = ""
local COMP_MASS = ""
local COMP_CPU = ""
local COMP_REQUIRES = ""
local COMP_PREFERED = ""
local COMP_AVAILABLE = ""
local STAT_QUALITY_TXT = ""
local SELECT_ITEM_TXT = Component.LookupText("CRAFTING_SELECT_ITEM");
local POWER_FORMAT = "%.2f kW" --ToDo: Localize
local MASS_FORMAT = "%.2f kg" --ToDo: Localize
local CPU_FORMAT = "%01d cores" --ToDo: Localize
local CONSTRAINTS_TABLE = {}

local CRAFTING_UI_LOCK_DURATION = 15;

local PROGRESSION_CERT_IDS = {};

local BAG_UPDATE = nil;
local CRAFTING_UPDATE = nil;
local GEAR_UPDATE = nil;
local CERT_UPDATE = nil;
local CFT_CERT_UPDATE = nil;

INGAME_HOST = "";
API_HOST = "";

-- VARIABLES
CFT_GLOBALS = {}
CFT_GLOBALS.g_charId = nil;
CFT_GLOBALS.d_available_recipes = {};
CFT_GLOBALS.d_recipes = {};
CFT_GLOBALS.d_resource_types = nil;
CFT_GLOBALS.g_recipe_certs = {};
CFT_GLOBALS.d_recipe_tables = { [0]={} };
CFT_GLOBALS.g_recipetree_as_list = {};
CFT_GLOBALS.g_filter_craftable = false;
CFT_GLOBALS.g_recipe_filter = ""

CFT_RECIPES = {}

local current_menu = nil;

local w_RecipeWidgets = {}
local w_ItemToolTip = nil;
local g_RecipeListOffest = 0;

local d_resource_types_table = {};
local d_selected_recipe = nil;
local d_current_recipe = nil;
local d_tutorial_recipe = nil;

local d_filtered_recipes = {};

local d_inventory = {}
local cb_inv_update = nil;

local w_WorkBenchWidgets = {};
local d_workbenches = {};	-- displayed workbenches
local d_wb_purchasable = {} -- purchasable benches
local g_selected_workbench = nil;
local g_WorkBenchListOffest = 0;

local cb_wb_update = nil;
local g_wb_update_attempts = 0;
local d_last_workbench_update_time = nil;
local g_purchasing_workbenches = {};
local g_waiting_for_mark_complete = false;

local d_InputMenuItems = {}
local w_InputMenuWidgets = {};
local g_InputMenuOffset = 0;
local g_SelectedInput = nil;
local d_SelectedInputItem = nil;

local d_num_parallel_builds = 1;
local cb_HoldSliderButton = nil;

local g_manufacture_post_wb_update = false;

local w_OutputPreviews = {};
local g_OutputPreviewOffset = 0;

local g_StatsOffest = 0;
local d_Stats = {};
local d_PlayerCerts = {};

local d_gear_inventory = {}
local w_CompareWidgets = {};
local g_CompareOffset = 0;
local d_CompareItemCount = 0;

local d_compare_item_info = nil;
local g_HideStats = false;

local g_PreviewItem = nil;
local g_PreviewItems = {};

local w_CYLINDERS = {};

local w_RequirementIcons = {}

local g_workbenchPreview = nil;

local w_MODELS = {
	PARENT = nil,
	MAIN = nil,
	SUBCOMPONENTS = {},
	OUTPUT = nil;
	OUTPUT_PLATE = nil;
}

local g_request_queue = {};
local cb_request = nil;  

local cb_please_wait = nil;

local g_resolution_dirty = true;

local g_playing_sound = false;
local g_keep_closed = false;
local g_initialized = false;

local d_recipe_list_id = BLUEPRINT_BUILD_ID;

local g_unlock_req_via_manu = false;

local g_screen_ratio = 1;

local d_interaction_guid = 0; -- random number generated on open

-- recipe tables

local d_recipe_tree = { name="Blueprints", id=-1, open=true, children={ [0]={ id=0,open=false, name="Misc.", total_count=0, children={} } } };


-- EVENTS
function OnComponentLoad()
	INGAME_HOST = System.GetOperatorSetting("ingame_host");
	API_HOST = System.GetOperatorSetting("clientapi_host");

	--[[
	LIB_SLASH.BindCallback({slash_list="up_inv", description="update inventory", func=function()
		log(tostring(d_inventory) )
		end});
	
	LIB_SLASH.BindCallback({slash_list="up_manu", description="update workbenches", func=function()
		log(tostring(d_workbenches) )
		end});
	
	LIB_SLASH.BindCallback({slash_list="resTb", description="update workbenches", func=function()
		log(tostring(CFT_GLOBALS.d_resource_types ) )
		end});	
	LIB_SLASH.BindCallback({slash_list="rt", description="update workbenches", func=function()
		--log(tostring(recipe_tables));
		WebResponseFailure( {status="???", data={message="testing", code = "ERR_UNKNOWN"}}, "ui_testing");
		end});	
	
	LIB_SLASH.BindCallback({slash_list="cft_out", description="update workbenches", func=function()
			POPUP_TITLE:SetText(Component.LookupText( "CRAFTING_OUTPUT" ));
			local text = "happy"
			for i =1, 20 do
				text = text.."\nhappy"..i;
			end
			SetScrollText( text, POPUP_TEXT, POPUP_SCROLL, POPUP_ROW );
			POPUP_DIALOG:Show();
		end});		
		
	LIB_SLASH.BindCallback({slash_list="cft_err", description="update workbenches", func=function()
		WebResponseFailure( {data={ code="ERR", message="Indeed"}, status="whatever"}, "Sup Bro" )
	end});		
	
	LIB_SLASH.BindCallback({slash_list="cft_p", description="update workbenches", func=function()
		WB_PURCHASEPROMPT:Show()
	end});		
	
	
	LIB_SLASH.BindCallback({slash_list="cft_p", description="update workbenches", func=function()
		OnPlayerReady();
	end});
	
	LIB_SLASH.BindCallback({slash_list="cft_cert", description="update workbenches", func=function()
		log( tostring(CFT_GLOBALS.g_recipe_certs))
	end});		
	
	LIB_SLASH.BindCallback({slash_list="cft_hide", description="update workbenches", func=function()
		FRAME:Hide();
		BG_FRAME:Hide();
		RIGHT_WING:Hide();
		LEFT_WING:Hide();
		VisualSlotter.Activate(false);
	end});
	
	LIB_SLASH.BindCallback({slash_list="cr", description="craft", func=function()
		local args = { success=true,
		  output={ {resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
				}
		}
		OnWBUnloadRequestResponse(args);
	end});
			
	LIB_SLASH.BindCallback({slash_list="cr2", description="craft", func=function()
		local args = { success=true,
		  output={ 
					{
						durability={ pool=5000, current=1000},
						attribute_modifiers={ [954]=441, [952]=-50.921437, [29]=2.064591 },
						owner_guid=9152230211399776504,
						item_id=9179030986069149181,
						item_sdb_id=77919,
						quality=841
					}
				}
		}
		OnWBUnloadRequestResponse(args);
	end});
	
	LIB_SLASH.BindCallback({slash_list="cr3", description="craft", func=function()
		local args = { success=true,
		  output={ {resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{resource_type="0", quantity=25, item_sdb_id=54003},{resource_type="0", quantity=25, item_sdb_id=54003}, {resource_type="0", quantity=25, item_sdb_id=54003},
					{
						durability={ pool=5000, current=1000},
						attribute_modifiers={ [954]=441, [952]=-50.921437, [29]=2.064591 },
						owner_guid=9152230211399776504,
						item_id=9179030986069149181,
						item_sdb_id=77919,
						quality=841
					}
				}
		}
		OnWBUnloadRequestResponse(args);
	end});
	
	LIB_SLASH.BindCallback({slash_list="cr4", description="craft", func=function()
		local args = { success=true,
			output={
					{
						durability={ pool=5218, current=1000},
						attribute_modifiers={ [956]=7, [954]=498, [29]=2.176834, [952]=-101.689625 },
						type_code = 244,
						created_at = 1234,
						updated_at = 1234,
						bound_to_owner=false,
						owner_guid=9152230211399776504,
						item_id=9179030986069149181,
						quality=859,
						item_sdb_id=77948,
					}
				},
			blueprint_id = 80431,
		}
		OnWBUnloadRequestResponse(args);
	end});
	
	LIB_SLASH.BindCallback({slash_list="cr5", description="craft", func=function()
		local args = { success=true,
			output={
					{
						durability={ pool=5218, current=1000},
						attribute_modifiers={ [956]=7, [954]=498, [952]=-50.906250 },
						type_code = 244,
						created_at = 1234,
						updated_at = 1234,
						bound_to_owner=false,
						owner_guid=9152230211399776504,
						item_id=9179030986069149181,
						quality=859,
						item_sdb_id=79166,
					}
				},
			blueprint_id = 80327,
		}
		OnWBUnloadRequestResponse(args);
	end});
	--]]
	
	--[[ tutorial test slash commands
	LIB_SLASH.BindCallback({slash_list="tut_test1", description="craft", func=function()
		if (ScriptedTutorial.HasFlag("listen_Unload")) then
			local args = { output={ {item_sdb_id='81896'}}};
			ScriptedTutorial.DispatchEvent("OnWorkbenchUnload", args);
		end
	end});
	
	LIB_SLASH.BindCallback({slash_list="tut_test2", description="craft", func=function()
		if (ScriptedTutorial.HasFlag("listen_Unload")) then
			local args = { output={{item_sdb_id='84454'}} };
			ScriptedTutorial.DispatchEvent("OnWorkbenchUnload", args);
		end
	end});
	
	LIB_SLASH.BindCallback({slash_list="tut_test2", description="craft", func=function()
		if (ScriptedTutorial.HasFlag("listen_Unload")) then
			local args = { output={{item_sdb_id='84454'}} };
			ScriptedTutorial.DispatchEvent("OnWorkbenchUnload", args);
		end
	end});
	
	LIB_SLASH.BindCallback({slash_list="tut_test3", description="craft", func=function()
		if (ScriptedTutorial.HasFlag("listen_Unload")) then
			local args = { output={{item_sdb_id='77655'}} };
			ScriptedTutorial.DispatchEvent("OnWorkbenchUnload", args);
		end
	end});
	--]]	

	VisualSlotter.OnSubmit = OnBGSelect;
	VisualSlotter.OnBack = OnBGSelect;

	RIGHT_WING:SetInteractable(true);
	RIGHT_WING:SetParam("cullalpha", 0);
	RIGHT_WING:SetScene("sinvironment");
	
	LEFT_WING:SetInteractable(true);
	LEFT_WING:SetParam("cullalpha", 0);
	LEFT_WING:SetScene("sinvironment");
	
	-- set up background catcher to hang out in the back
	BG_FRAME:SetScene("sinvironment");
	BG_FRAME:SetInteractable(true);
	BG_FRAME:SetParam("cullalpha", 0);
	local BG_ANCHOR = BG_FRAME:GetAnchor();
	BG_ANCHOR:BindToCamera();
	BG_ANCHOR:SetParam("translation", {x=0,y=-2,z=0});	-- TODO: Investigate bug with tracking frames not sorting interaction by depth
	BG_ANCHOR:SetParam("scale", {x=8,y=8,z=8});
	
	INPUTS.CENTRAL_ANCHOR = Component.CreateAnchor();	-- this is the anchor about which all the CraftingComponents rotate
	INPUTS.CENTRAL_ANCHOR:SetScene("sinvironment")
	INPUTS.CENTRAL_ANCHOR:SetParam("translation", {x=0, y=-1.5, z=2});
	local comp_entries = INPUTS.GROUP:GetChild("entries");
	local N = comp_entries:GetChildCount()
	for i=1, N do
		local WIDGET = comp_entries:GetChild(i);
		local INPUT = {		
			GROUP		= WIDGET,
			NAME_BG		= WIDGET:GetChild("name_bg"),
			NAME		= WIDGET:GetChild("name"),
			COUNT_BG	= WIDGET:GetChild("count_bg"),
			COUNT		= WIDGET:GetChild("count"),
			ITEM		= nil,
			ANCHOR		= Component.CreateAnchor(),
			FRAME		= Component.CreateFrame("TrackingFrame"),
		};
		INPUT.ANCHOR:SetParent(INPUTS.CENTRAL_ANCHOR);
		INPUT.ANCHOR:SetScene("sinvironment");
		
		-- 3D-ify the 2D elements
		INPUT.FRAME_HOLDER = Component.CreateWidget('<Group dimensions="dock:fill"/>', INPUT.FRAME);
		INPUT.FRAME:SetInteractable(true);
		INPUT.FRAME:SetScene("sinvironment");
		INPUT.FRAME:BindEvent("OnEscape", function()
			if (current_menu) then
				OnBGSelect();
			else
				OnEscape();
			end
		end);
		INPUT.FRAME:GetAnchor():SetParent(INPUT.ANCHOR, false, true);
		INPUT.FRAME:GetAnchor():SetParam("scale", {x=.15, y=.20, z=.15});
		Component.FosterWidget(INPUT.GROUP, INPUT.FRAME_HOLDER);
		INPUT.GROUP:SetDims("dock:fill");
		
		INPUT_ENTRIES[i] = INPUT;
	end
	
	INPUT_ENTRIES[1].ANCHOR:SetParam("translation", {x=-0.2, y=0, z=.1} );
	INPUT_ENTRIES[2].ANCHOR:SetParam("translation", {x=0.2, y=0, z=0.1} );
	INPUT_ENTRIES[3].ANCHOR:SetParam("translation", {x=-0.6, y=0, z=0.1} );
	INPUT_ENTRIES[4].ANCHOR:SetParam("translation", {x=0.6, y=0, z=0.1} );
	
	INPUT_ENTRIES[5].ANCHOR:SetParam("translation", {x=-0.2, y=0, z=-.25} );
	INPUT_ENTRIES[6].ANCHOR:SetParam("translation", {x=0.2, y=0, z=-.25} );
	INPUT_ENTRIES[7].ANCHOR:SetParam("translation", {x=-0.6, y=0, z=-.25} );
	INPUT_ENTRIES[8].ANCHOR:SetParam("translation", {x=0.6, y=0, z=-.25} );
	INPUT_ENTRIES[9].ANCHOR:SetParam("translation", {x=-1, y=0, z=-.25} );
	INPUT_ENTRIES[10].ANCHOR:SetParam("translation", {x=1, y=0, z=-.25} );
	
	INPUT_AMT_LIST = ItemSelection.CreateList(INPUT_AMT_BODY);
	INPUT_AMT_BACK = RoundedPopupWindow.Create(INPUT_AMT_BACK);
	
	INPUT_AMT_ACCEPT = Button.Create(INPUT_AMT_ACCEPT);
	INPUT_AMT_ACCEPT:Bind( OnInputSelectAccept );
	INPUT_AMT_ACCEPT:Autosize("right");
	INPUT_AMT_ACCEPT:SetTextKey("ACCEPT", true);
	
	INPUT_AMT_CANCEL = Button.Create(INPUT_AMT_CANCEL);
	INPUT_AMT_CANCEL:Bind( OnInputSelectDecline );
	INPUT_AMT_CANCEL:Autosize("left");
	INPUT_AMT_CANCEL:SetTextKey("CANCEL", true);
	
	MANUFACTURE_BTN = Button.Create(MANUFACTURE_BTN);
	MANUFACTURE_BTN:Bind( OnManufactureRequest );
	MANUFACTURE_BTN:Autosize("center");
	MANUFACTURE_BTN:SetTextKey("CRAFTING_MANUFACTURE", true);
	MANUFACTURE_BTN:AddHandler( "OnMouseEnter", OnManufactureEnter);
	MANUFACTURE_BTN:AddHandler( "OnMouseLeave", OnManufactureLeave);
	MANUFACTURE_BTN:TintPlate("#006F00");
	MANUFACTURE_BTN:Hide();
	
	DESCRIPTION_SCROLL = RowScroller.Create(DESCRIPTION_GROUP);
	DESCRIPTION_SCROLL:SetSlider( RowScroller.SLIDER_DEFAULT );
	DESC_ROW = DESCRIPTION_SCROLL:AddRow(DESCRIPTION_TEXT);
		
	POPUP_BACK = RoundedPopupWindow.Create(POPUP_BACK);
	POPUP_CLOSE = Button.Create(POPUP_CLOSE);
	POPUP_CLOSE:Bind( OnPopup_Close );
	POPUP_CLOSE:Autosize("center");
	POPUP_CLOSE:SetTextKey("CLOSE", true);
	
	POPUP_SCROLL = RowScroller.Create(POPUP_GROUP);
	POPUP_SCROLL:SetSlider( RowScroller.SLIDER_DEFAULT );
	POPUP_ROW = POPUP_SCROLL:AddRow(POPUP_TEXT);
	
	WB_PURCHASEPROMPT = RoundedPopupWindow.Create(WB_PURCHASEPROMPT);
	WB_PURCHASEPROMPT:SetTitle(Component.LookupText("CRAFTING_PURCHASE_WB_TITLE"), "#FFFFFF", "center")
	WB_PURCHASEPROMPT:Close();
	WB_PURCHASEPROMPT:EnableClose( true, CloseWorkbenchPurchaseScreen );
	Component.FosterWidget(WB_PURCHASEPROMPT_BODY, WB_PURCHASEPROMPT:GetBody(), "full");
	
	WB_PURCHASEPROMPT_CANCEL = Button.Create(WB_PURCHASEPROMPT_CANCEL);
	WB_PURCHASEPROMPT_CANCEL:Bind( CloseWorkbenchPurchaseScreen );
	WB_PURCHASEPROMPT_CANCEL:Autosize("center");
	WB_PURCHASEPROMPT_CANCEL:SetTextKey("CRAFTING_CANCEL_PURCHASE", true);
	WB_PURCHASEPROMPT_CANCEL:TintPlate(Button.DEFAULT_RED_COLOR);
	
	PURCHASE_WORKBENCHES_BTN = Button.Create(PURCHASE_WORKBENCHES);
	PURCHASE_WORKBENCHES_BTN:Bind( OpenWorkbenchPurchaseScreen );
	PURCHASE_WORKBENCHES_BTN:Autosize("left");
	PURCHASE_WORKBENCHES_BTN:SetTextKey("CRAFTING_PURCHASE_WB_TITLE", true);
	
	REFINE_BUTTON = Button.Create(REFINE_BUTTON);
	REFINE_BUTTON:Bind( OnRefineRecipes );
	REFINE_BUTTON:SetTextKey("CRAFTING_REFINE", false);
	REFINE_BUTTON:AddHandler( "OnMouseEnter", OnRefineEnter);
	REFINE_BUTTON:AddHandler( "OnMouseLeave", OnButtonLeave);
	
	BATTLEFRAME_BUTTON = Button.Create(BATTLEFRAME_BUTTON);
	BATTLEFRAME_BUTTON:Bind( OnBattleframeRecipes );
	BATTLEFRAME_BUTTON:SetTextKey("CRAFTING_BATTLEFRAME", false);
	BATTLEFRAME_BUTTON:AddHandler( "OnMouseEnter", OnBattleframeEnter);
	BATTLEFRAME_BUTTON:AddHandler( "OnMouseLeave", OnButtonLeave);
	BATTLEFRAME_BUTTON:Enable(false);
	
	RESEARCH_BUTTON = Button.Create(RESEARCH_BUTTON);
	RESEARCH_BUTTON:Bind( OnResearchRecipes );
	RESEARCH_BUTTON:SetTextKey("CRAFTING_RESEARCH", false);
	RESEARCH_BUTTON:AddHandler( "OnMouseEnter", OnResearchEnter);
	RESEARCH_BUTTON:AddHandler( "OnMouseLeave", OnButtonLeave);
	
	INPUT_MENU_SELECTED_BTN = Button.Create(INPUT_MENU_SELECTED_BTN);
	INPUT_MENU_SELECTED_BTN:Bind( OnUseResource );
	INPUT_MENU_SELECTED_BTN:SetTextKey("ACCEPT", "right");
	INPUT_MENU_SELECTED_BTN:AddHandler( "OnMouseEnter", OnUseResourceEnter);
	INPUT_MENU_SELECTED_BTN:AddHandler( "OnMouseLeave", HideTooltip);
	INPUT_MENU_SELECTED_BTN:TintPlate("#1fff1f");
	
	TRACK_BTN = Button.Create(TRACK_BTN);
	TRACK_BTN:Bind( OnTrack );
	TRACK_BTN:SetTextKey("SHOPPING_CART_TRACK_RECIPE");
	TRACK_BTN:AddHandler( "OnMouseEnter", OnTrackEnter);
	TRACK_BTN:AddHandler( "OnMouseLeave", OnTrackLeave);
	TRACK_BTN:TintPlate("#1fdf1f");
	TRACK_BTN:Hide();
	
	TUTORIAL_BTN = Button.Create(TUTORIAL_BTN);
	TUTORIAL_BTN:Bind( OnTutorial );
	TUTORIAL_BTN:SetTextKey("TUTORIAL_BUTTON");
	TUTORIAL_BTN:AddHandler( "OnMouseEnter", OnTutorialEnter);
	TUTORIAL_BTN:AddHandler( "OnMouseLeave", HideTooltip);
	TUTORIAL_BTN:TintPlate("#1fdf1f");
	TUTORIAL_BTN:Pulse( true, {tint="#008F00", freq=1.25} );
	
	CHECKBOX_CRAFT = CheckBox.Create(RECIPES:GetChild("craftable_toggle"):GetChild("Checkbox_Craftable"))
	CHECKBOX_CRAFT:AddHandler("OnStateChanged", OnToggleCraftable)
	CHECKBOX_CRAFT:AddHandler("OnMouseEnter", OnToggleCraftableEnter)
	CHECKBOX_CRAFT:AddHandler("OnMouseLeave", HideTooltip)
	
	MANUFACTURE_BTN:Hide();
	
	g_InputMenuOffset = 0;
	SetRecipeOffset( 0 );
	
	local function UpdatePromptOpacity()
		local alpha = 0;
		if (RECIPES_RECIPEFILTER:GetText() == "") then
			if (RECIPES_RECIPEFILTER:HasFocus()) then	alpha = .6;
			else					alpha = 1;
			end
		end
		RECIPES_EMPTYPROMPT:ParamTo("alpha", alpha, .1, 0, "ease-in");
	end
	
	-- bind text input events
	RECIPES_RECIPEFILTER:BindEvent("OnGotFocus", function()
		UpdatePromptOpacity();
	end);
	
	RECIPES_RECIPEFILTER:BindEvent("OnLostFocus", function()
		UpdatePromptOpacity();
	end);
	
	RECIPES_RECIPEFILTER:BindEvent("OnTextChange", function(args)
		System.PlaySound(SOUND_KEYSTROKE);
		if (args.OnTextChange) then
			args.OnTextChange(TIF);
		end
		FilterRecipes();
		UpdatePromptOpacity();
	end);
	
	COMP_QUALITY = Component.LookupText("STAT_QUALITY");
	COMP_POWER = Component.LookupText("STAT_POWER");
	COMP_MASS = Component.LookupText("STAT_MASS");
	COMP_CPU = Component.LookupText("STAT_CPU");
	COMP_REQUIRES = Component.LookupText("CRAFTING_REQUIRES");
	COMP_PREFERED = Component.LookupText("CRAFTING_PREFERED_STAT");
	COMP_AVAILABLE = Component.LookupText("CRAFTING_AVAILABLE");
	CRAFTING_LOW_QUANTITY = Component.LookupText("CRAFTING_LOW_QUANTITY");
	
	CONSTRAINTS_TABLE = {mass={name=COMP_MASS, format=MASS_FORMAT}
					, power={name=COMP_POWER, format=POWER_FORMAT}
					, cpu={name=COMP_CPU, format=CPU_FORMAT}
					}
	
	STAT_QUALITY_TXT = Component.LookupText("STAT_QUALITY");
	STATS_SCROLL = RowScroller.Create(STATS);
	STATS_SCROLL:SetSlider( RowScroller.SLIDER_DEFAULT );
	
	local progression = Game.GetProgressionUnlocks();
	for lvl,unlock in pairs(progression) do
		for branch,cert_id in pairs(unlock.certs) do
			PROGRESSION_CERT_IDS[tostring(cert_id)] = true;
		end
	end
	
	
	function SliderButton_Hold(value)
		IncrementParallelBuildCount(value);
		cb_HoldSliderButton = callback(SliderButton_Hold, value, 0.0625)
	end
	
	function Slider_MouseUp()
		if( cb_HoldSliderButton ) then
			cancel_callback(cb_HoldSliderButton)
			cb_HoldSliderButton = nil;
		end
	end
	
	function Slider_MouseDown(args)
		local value = tonumber(args.widget:GetTag());
		if cb_HoldSliderButton then
			cancel_callback(cb_HoldSliderButton)
			cb_HoldSliderButton = nil;
		end
		IncrementParallelBuildCount(value);
		cb_HoldSliderButton = callback(SliderButton_Hold, value, 0.5);
	end
	
	NUM_PARALLEL_SLIDER:BindEvent("OnStateChanged", function(args) 
													if( d_current_recipe ) then
														local val = args.widget:GetPercent();
														val = math.floor( val * d_current_recipe.max_parallel + 0.5 );
														UpdateParallelBuildCount(val);
													else
														UpdateParallelBuildCount(1);
													end
												end );
	
	local parallel_dec = NUM_PARALLEL:GetChild("dec_button"):GetChild("focus");
	parallel_dec:BindEvent("OnMouseDown", Slider_MouseDown );
	parallel_dec:BindEvent("OnMouseUp", Slider_MouseUp );
	parallel_dec:BindEvent("OnMouseLeave", Slider_MouseUp );
	
	local parallel_inc = NUM_PARALLEL:GetChild("inc_button"):GetChild("focus");
	parallel_inc:BindEvent("OnMouseDown", Slider_MouseDown );
	parallel_inc:BindEvent("OnMouseUp",Slider_MouseUp );
	parallel_inc:BindEvent("OnMouseLeave", Slider_MouseUp );
	
	ResizeWingGroups();
	VisualSlotter.LockZoom(true)
	
	CRAFT_TIP:SetTextKey("CRAFTING_RCP_SELECT_TT")
end

function OnStreamProgress()
	if( FRAME:IsVisible() )then
		-- we've started zoning, clean up and close interface
		OnClose();
	end
end

function ResizeWingGroups()
	--local screen_width, screen_height = Component.GetScreenSize(true);
	local screen_width = 1280;
	local screen_height = 800;
	
	g_screen_ratio = 800/screen_height;
	
	local scale = 0.175 * g_screen_ratio;
	local RIGHT_ANCHOR = RIGHT_WING:GetAnchor();
	--RIGHT_ANCHOR:BindToScreen();
	--RIGHT_ANCHOR:SetParam("translation", {x=1.0,y=-0.11,z=4});
	--RIGHT_ANCHOR:SetParam("translation", {x=0,y=0,z=2.7});
	RIGHT_ANCHOR:SetParam("translation", {x=2.05,y=-1.5,z=2.7});
	RIGHT_ANCHOR:SetParam("rotation", {axis={x=0.0,y=0,z=1}, angle=22.5});
	RIGHT_ANCHOR:SetParam("scale", {x=scale,y=scale,z=scale});
	
	local LEFT_ANCHOR = LEFT_WING:GetAnchor();
	--LEFT_ANCHOR:BindToScreen();
	LEFT_ANCHOR:SetParam("translation", {x=-1.65,y=-1.5,z=2.7});
	LEFT_ANCHOR:SetParam("rotation", {axis={x=0.0,y=0,z=1}, angle=-22.5});
	LEFT_ANCHOR:SetParam("scale", {x=scale,y=scale,z=scale});
	
	-- right wing
	local height = screen_height;
	local width = screen_width * 0.28 * g_screen_ratio;
	RECIPES:SetDims( "right:0%; bottom:"..(height*0.1-16).."; width:"..width..";height:"..height*0.5);

	local num_wb = math.max( math.floor(height*0.4/WORKBENCH_ENTRY_HEIGHT),1);
	WORKBENCHES:SetDims( "right:0%; top:"..(height*0.1+50).."; width:"..width..";height:"..num_wb * WORKBENCH_ENTRY_HEIGHT);
	local purchase_top = height*0.1 + 400

	PURCHASE_WORKBENCHES:SetDims("height:_; top:"..purchase_top);
	
	PURCHASE_VIP_BTN = Button.Create(PURCHASE_VIP);
	PURCHASE_VIP_BTN:Bind( OnShowVIPProgram );
	PURCHASE_VIP_BTN:Autosize("left");
	PURCHASE_VIP_BTN:SetTextKey("GO_VIP", true);
	PURCHASE_VIP_BTN:TintPlate(Button.DEFAULT_YELLOW_COLOR);
	PURCHASE_VIP:SetDims("height:_; top:"..purchase_top);
	--top:"..purchase_top+48"
	
	local vip_purchase_bounds = PURCHASE_VIP_BTN:GetBounds();
	--VIP_PERK_TIP:SetDims("right:0%-"..(vip_purchase_bounds.width+8).."; width:"..(292-vip_purchase_bounds.width).."; top:"..purchase_top+48)
	
	-- left wing
	local top = -screen_height * 0.4;
	PREVIEW_TITLE:SetDims("left:0%; top:"..top.."; width:"..width.."; height:20");
	top = top + 24;
	local output_top = top;
	OUTPUT:SetDims("left:0%; top:"..top.."; width:"..width.."; height:96")
	top = top + 110;	
		
	local stats_height = screen_height * 0.4;
	STATS:SetDims( "left:0%; top:"..top.."; width:"..width..";height:"..stats_height );
	STATS_SCROLL:UpdateSize({height=stats_height, width=width});
	top = top + stats_height+8;
	COMPARE_GROUP:SetDims( "left:0%; top:"..top.."; width:"..width..";height:52" );
	top = top + 60;	
	
	local output_bottom = top;
	WALLET:SetDims( "left:0%; top:"..top.."; width:"..width..";height:40" );
	top = top + 48;
	CHAT_PANEL:SetDims( "left:0%; top:"..top.."; width:"..width..";height:160" )
	
	OUTPUT_PREVIEW:SetDims("left:0%; top:"..output_top.."; bottom:"..output_bottom.."; width:"..width );
end

function OnResolutionChanged()
	OnClose();
	
	ResizeWingGroups();
	
	g_resolution_dirty = true;	
end

function OnPlayerReady()
	if( g_initialized ) then
		return;
	end
	g_initialized = true;
	local name, faction, race, sex, id = Player.GetInfo()
	CFT_GLOBALS.g_charId = id;
	CFT_GLOBALS.d_resource_types  = Game.GetResourceTypesList();
	
	local parent_to_child = {}
	for _, data in pairs(CFT_GLOBALS.d_resource_types ) do
		if( not parent_to_child[tostring(data.parent_id)] ) then
			parent_to_child[tostring(data.parent_id)] = {};
		end
		table.insert(parent_to_child[tostring(data.parent_id)], data.id );
	end
	
	CFT_CERT_UPDATE = WebCache.MakeUrl( "crafting_certs", CFT_GLOBALS.g_charId);
	WebCache.Subscribe( CFT_CERT_UPDATE, OnRecipeCertResponse);
	
	WebCache.Request(CFT_CERT_UPDATE);
	
	OnRecipeListUpdate();
	
	-- create empty tables for all entries in the the recipe tree
	CFT_GLOBALS.d_recipe_tables[0] = {}; -- handle the unknown case
	
	-- generate a tree based on the blueprint resource_type
	function SetupRecipeTree(tree, id)
		CFT_GLOBALS.d_recipe_tables[id] = {}; -- create an empty recipe table for each recipe category

		local res_info = parent_to_child[ tostring(id) ];
		if(res_info)then
			for _, id in pairs(res_info) do
				local data = CFT_GLOBALS.d_resource_types[ tostring(id) ];
				if( data.id ~= 0 ) then
					local info = { id=data.id, open=false, name=data.name, children={} };
					table.insert( tree.children, { id=data.id, open=false, name=data.name, children={} } );
				end
			end
		end
		
		for _,child in pairs(tree.children) do
			SetupRecipeTree( child, child.id );
		end
	end	
	SetupRecipeTree( d_recipe_tree, BLUEPRINT_TYPE_ID );
	
	function sort_children( tree )
		for _,child in pairs(tree.children) do
			sort_children( child );
		end
		
		table.sort(tree.children, function(a,b) 
									return a.name < b.name;
								end);
	end	
	sort_children( d_recipe_tree );
		
	BAG_UPDATE = WebCache.MakeUrl("bag", CFT_GLOBALS.g_charId);
	CRAFTING_UPDATE = WebCache.MakeUrl("crafting", CFT_GLOBALS.g_charId);
	GEAR_UPDATE = WebCache.MakeUrl( "gear_items", CFT_GLOBALS.g_charId);
	CERT_UPDATE = WebCache.MakeUrl( "certs", CFT_GLOBALS.g_charId);
	
	-- Web Cache Subscribing
	WebCache.Subscribe( BAG_UPDATE, BagResponse);
	WebCache.Subscribe( CRAFTING_UPDATE, CraftInvResponse);
	WebCache.Subscribe( GEAR_UPDATE, GearResponse);
	WebCache.Subscribe( CERT_UPDATE, function(args, err) 
			if( err ) then
				warn( tostring( err ) )
			else
				for frame, certs in pairs(args)do
					local cert_map = {}
					for _, cert in pairs(certs)do
						cert_map[tostring(cert)] = true;
					end
					d_PlayerCerts[tostring(frame)] = cert_map;
				end
			end
		end );
	if( not WebCache.GetCacheAge(CERT_UPDATE) )then
		WebCache.Request( CERT_UPDATE );
	end
	UpdateInventory(0);
	UpdateWorkbench();
end

function OnRecipeListUpdate()
	CFT_GLOBALS.d_recipes = Game.GetRecipeList()
end

function OnMessage( args )
	if (args.data == "open") then
		OnOpen();
	elseif (args.type == "close") then
		OnClose();
	elseif( args.type == "craft" ) then
		if(d_tutorial_recipe ~= args.data)then
			d_tutorial_recipe = args.data;
			if( FRAME:IsVisible() ) then
				SelectRecipe(nil);
			end
		end
	end
end

function OnOpen()
	System.PlaySound("Play_State_Interact")
	System.PlaySound("Play_SFX_NewYou_IntoAndLoop");
	
	WebCache.Request(CFT_CERT_UPDATE);
	
	if( g_keep_closed ) then
		FRAME:Hide();
		CRAFT_TIP:Hide();
		function close()
			Component.SetInputMode(nil);
			Component.PostMessage("Sinvironment:main", "activate", nil);
			ErrorDialog.Hide()
			System.PlaySound("Play_State_InteractNone");
		end

		ErrorDialog.Display( Component.LookupText("CRAFTING_LOCKED", CRAFTING_UI_LOCK_DURATION), close );
		ErrorDialog.AddOption( {label=Component.LookupText("Close"), OnPress=close} );
		return;
	end

	if(g_resolution_dirty)then
		ResolutionUpdate()
	end

	SelectRecipe(nil);
	
	Component.ActivateUserKeybinds(true);
	NavWheel.Close();
	
	Sinvironment.SetManualCamera({x=0, y=-4.5, z=2.75}, {x=0, y=0, z=2.7});
	Sinvironment.SetManualCamera({x=0, y=-4.5, z=2.65}, {x=0, y=0, z=2.65}, 0.5);
	FRAME:Show();
	BG_FRAME:Show();
	
	
	RIGHT_WING:Show();
	LEFT_WING:Show();
	
	Component.GenerateEvent("MY_FOSTER_CHAT_TAB", {foster="CraftingEnvironment:CHAT_PANEL", fosterheight=(CHAT_PANEL:GetBounds().height)})
	UpdateInventory(0);
	DelayedWorkbenchUpdate(0);
	--InitializeCylinders()
	
	w_ItemToolTip = LIB_ITEMS.CreateToolTip(Component.GetWidget("tooltip_container"));
	w_ItemToolTip.GROUP:SetDims("top:0; left:0; width:200; height:200");
	
	-- show crafting stuffs
	for _,INPUT in pairs(INPUT_ENTRIES) do
		INPUT.FRAME:Show();
	end
	
	Wallet.DisplayBalance("crystite", "redbeans");
	Wallet.Subscribe("crystite", "redbeans");
	Wallet.Refresh();
	Wallet.Foster(WALLET);
	
	DisplayRecipes();
	d_interaction_guid = math.random(100000000);
	HTTP.IssueRequest(API_HOST.."/api/v3/ui_actions", "POST", {{screen="crafting", action="open", screen_reference_id=d_interaction_guid}});
	
	HideMouseBlock(); -- in case this is visible close it 
	UpdateWorkbench();
end

function OnEscape()
	if( current_menu ) then
		HideMenu();
	else
		OnClose();
	end
end

function OnError_Return()
	POPUP_DIALOG:Show(false);
end

function OnClose()
	if( FRAME:IsVisible() )then
		FRAME:Hide();
		Component.PostMessage("Sinvironment:main", "activate", nil);
		Component.GenerateEvent("MY_FOSTER_CHAT_TAB", {foster=nil})		
		Component.GenerateEvent("MY_CFT_REWARD_DISPLAY", {hide=true});
		System.PlaySound("Stop_SFX_NewYou_IntoAndLoop");
		
		HTTP.IssueRequest(API_HOST.."/api/v3/ui_actions", "POST", {{screen="crafting", action="close", screen_reference_id=d_interaction_guid}});
	end
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	System.PlaySound("Play_SFX_WebUI_Close");
	System.PlaySound("Play_State_InteractNone")
	Component.ActivateUserKeybinds(false);
	BG_FRAME:Hide();
	RIGHT_WING:Hide();
	LEFT_WING:Hide();
	HideMenu();
	HideRecipe();
	
	if( w_ItemToolTip ) then
		w_ItemToolTip:Destroy();
		w_ItemToolTip = nil;
		HideTooltip()
	end
	
	-- hide crafting stuffs
	for _,INPUT in pairs(INPUT_ENTRIES) do
		INPUT.FRAME:Hide();
	end
	
	Wallet.Foster( nil );
	Wallet.DisplayBalance(nil);
	Wallet.Subscribe(nil);
	
	if( cb_inv_update ) then
		cancel_callback( cb_inv_update );
		cb_inv_update = nil;
	end
	
	for _,WB in pairs(w_WorkBenchWidgets) do
		WB.PLATE.SCOBJ:Hide();
	end
end

function OnBGSelect()
	HideMenu();
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
end

function OnPopup_Close()
	POPUP_DIALOG:Hide();
end

-- INPUT EVENTS
function FindItemsForInput(INPUT)
	local items = {};
	local prefered_stat_id = INPUT.INPUT_REQ.resource_type;
	local attribute_map = d_current_recipe.attribute_map
	if( INPUT.MATERIALTYPE and INPUT.MATERIALTYPE > 0) then
		local valid_resc_types = CFT_ValidResourceTypes(INPUT.MATERIALTYPE);
		
		local valid_itemtypes = {};
		for t=1, #valid_resc_types do
			if( not attribute_map or attribute_map[ tostring(valid_resc_types[t] )] ) then
				table.insert( valid_itemtypes, valid_resc_types[t] )
			end
		end
		table.insert( valid_itemtypes, INPUT.MATERIALTYPE)
		-- prevent players from selection the same input type in optional input slots
		-- if they do, the second optional component will be accepted.
		local OPTIONAL_COMPONENT_TYPE = 1920;
		if( INPUT.MATERIALTYPE == OPTIONAL_COMPONENT_TYPE ) then 
			for id, ENTRY in pairs(INPUT_ENTRIES) do
				if(ENTRY and ENTRY ~= INPUT and ENTRY.MATERIALTYPE == OPTIONAL_COMPONENT_TYPE and ENTRY.ITEM)then
					for t=1, #valid_itemtypes do
						if( valid_itemtypes[t] == ENTRY.ITEM.root_info.item_subtype ) then
							table.remove( valid_itemtypes, t )
						end
					end
				end
			end
		end
		
		local stat_name = "quality";
		if( INPUT.INPUT_REQ.resource_type > 0 ) then
			stat_name = "stat"..INPUT.INPUT_REQ.resource_type;
		end
		
		if( INPUT.ITEM ) then
			local stat_value = INPUT.ITEM[stat_name];
			table.insert( items, {cmp_value=stat_value, item=INPUT.ITEM} );
		end
		
		for _,ITEM in pairs(d_inventory) do
			for t=1, #valid_itemtypes do
				if( ITEM.root_info.item_subtype == valid_itemtypes[t] and ITEM ~= INPUT.ITEM ) then
					if( IsItemAvailable( ITEM ) )then
						local stat_value = ITEM[stat_name];
						table.insert( items, {cmp_value=stat_value, item=ITEM} );
						break;
					end
				end
			end
		end
	end
	return items;
end

function OnInputSlotSelect( args )
	if( g_workbenchPreview ) then
		return;
	end
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	if( current_menu ~= INPUTS_MENU ) then
		HideMenu();
		current_menu = INPUTS_MENU;
	end
	
	local widget = args.widget:GetParent();
	local parent = widget:GetParent();
	local dims = widget:GetBounds();
	local pdims = parent:GetBounds();
	
	local INPUT = INPUT_ENTRIES[tonumber(widget:GetTag())];
	-- hide if no recipe to create or item's avaiable to slot
	local recipe = CFT_FindRecipeForInput(INPUT, true);
	if( recipe and g_SelectedInput == INPUT ) then
		OnCreateSelectedInput();
		return;
	end
	
	if( g_SelectedInput ) then
		UpdateInputInfo( g_SelectedInput, g_SelectedInput.ITEM, g_SelectedInput.QUANTITY );
		g_SelectedInput = nil;
	end
	
	-- populate menu with valid items
	
	g_SelectedInput = INPUT;
	
	d_InputMenuItems = FindItemsForInput(INPUT);

	if( not recipe and #d_InputMenuItems <= 0 and INPUT.MATERIALTYPE == 0 ) then
		HideMenu();
		return;
	end
	
	table.sort( d_InputMenuItems,
					function( a, b )
						if( not a.cmp_value ) then
							return false;
						elseif( not b.cmp_value ) then
							return true;
						else
							return a.cmp_value > b.cmp_value
						end
					end );
					
	if( INPUT.ITEM and INPUT.MATERIALTYPE ~= 0 ) then
		table.insert(d_InputMenuItems, 1, {empty=true}  );	
	end
	
	if( recipe ) then
		table.insert(d_InputMenuItems, 1, {create=true} );
	else
	--[[		recipe = CFT_FindRecipeForInput(INPUT, false);
		if( recipe ) then
			("CRAFTING_NO_COMP_RCP");
		end
	--]]
	end
	
	SetInputMenuOffset( 0 );
	if( #d_InputMenuItems < #w_InputMenuWidgets ) then
		INPUT_MENU_SCROLL_BAR:Hide();
	else
		INPUT_MENU_SCROLL_BAR:Show();
		INPUT_MENU_SCROLL_BAR:SetParam( "thumbsize", #w_InputMenuWidgets/#d_InputMenuItems );
		INPUT_MENU_SCROLL_BAR:SetScrollSteps( #d_InputMenuItems - #w_InputMenuWidgets );
	end
	d_SelectedInputItem = INPUT.ITEM;
	DisplayInputsMenu( );
	-- highlight selected recipe input
	INPUT.PLATE.SCOBJ:SetParam("tint", "6f6f00");
	INPUTS_MENU:Show();
end

function OnInputMenuItemEnter(arg)
	local widget = arg.widget:GetParent();
	local INPUT = w_InputMenuWidgets[tonumber(widget:GetTag())];
	local item = d_InputMenuItems[tonumber(widget:GetTag()) + g_InputMenuOffset];
	
	local color = "#2f2f6f"
	INPUT.NAME_BG:SetParam( "tint", color );
	INPUT.STAT_BG:SetParam( "tint", color );
	INPUT.QUANTITY_BG:SetParam( "tint", color );
	if (item and item.item and item.item.itemInfo) then
		ShowItemTooltip(item.item.itemInfo);
		System.PlaySound(SOUND_MOUSE_OVER);
	elseif(item.create)then
		ShowTooltip(Component.LookupText("CRAFTING_CREATE_COMP_TT"));
	elseif(item.empty)then
		ShowTooltip(Component.LookupText("CRAFTING_EMPTY_COMP_TT"));
	else
		return;	
	end
end

function OnInputMenuItemLeave(arg)
	local widget = arg.widget:GetParent();
	local INPUT = w_InputMenuWidgets[tonumber(widget:GetTag())];
	local ITEM = d_InputMenuItems[tonumber(widget:GetTag()) + g_InputMenuOffset].item;
	local color = "#3f3f3f"
	INPUT.NAME_BG:SetParam( "tint", color);
	INPUT.STAT_BG:SetParam( "tint", color );
	INPUT.QUANTITY_BG:SetParam( "tint", color );
	if( ITEM and g_SelectedInput and g_SelectedInput.INPUT_REQ.quantity ) then
		if( g_SelectedInput.INPUT_REQ.quantity > 1 ) then
			if( not ITEM.quantity or g_SelectedInput.INPUT_REQ.quantity > ITEM.quantity ) then
				INPUT.QUANTITY_BG:SetParam("tint", "#6F0000" );
			end
		end
	end
	HideTooltip();
end

function OnInputMenuItemSelect(args)
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	if( not g_SelectedInput ) then
		HideMenu();
		warn("invalid component slot")
		return;
	end
	
	System.PlaySound("Play_UI_Beep_09");
	
	local widget = args.widget:GetParent();
	local index = widget:GetTag();
	
	local entry = d_InputMenuItems[tonumber(index)+g_InputMenuOffset];
	local menu_entry = entry.item;
	
	local current_quantity = tonumber(INPUT_MENU_QUANTITY:GetText())
	local use_resource = false;
	if( not d_SelectedInputItem and entry.empty)then
		use_resource = true;
	elseif(d_SelectedInputItem and d_SelectedInputItem == menu_entry) then	
		local quantity = menu_entry.available_quantity;
		if(d_SelectedInputItem == g_SelectedInput.ITEM )then
			quantity = quantity+ g_SelectedInput.QUANTITY
		end
		if( g_SelectedInput.INPUT_REQ.unlimited and current_quantity ~= quantity) then
			use_resource = false;
		elseif( g_SelectedInput.INPUT_REQ.unlimited and current_quantity == quantity ) then
			OnUseResource();
			return;
		else
			HideMenu();
			return;
		end
	elseif( not g_SelectedInput.INPUT_REQ.unlimited )then
		if(entry.create)then
			OnCreateInput();
			return;
		else
			d_SelectedInputItem = menu_entry;
			OnUseResource();
			return;
		end
	end
	
	if( use_resource ) then
		OnUseResource();
		return;
	end
	
	d_SelectedInputItem = nil;
	if(entry.create)then
		OnCreateInput();
	elseif(entry.empty)then
		TextFormat.Clear(INPUT_MENU_SELECTED_ITEM);
		INPUT_MENU_SELECTED_ITEM:SetTextKey("CRAFTING_NOTHING");
		INPUT_MENU_SELECTED_ITEM:SetTextColor("#FFFFFF")
		
		INPUT_MENU_MAX_QUANTITY:SetText("/0");
		INPUT_MENU_QUANTITY:SetText("0");
	else
		local TF = TextFormat.Create();
		TF:Concat( LIB_ITEMS.GetNameTextFormat(menu_entry.itemInfo, {quality = menu_entry.quality}));
		TF:ApplyTo(INPUT_MENU_SELECTED_ITEM);
		d_SelectedInputItem = menu_entry;
		if(g_SelectedInput.INPUT_REQ.unlimited) then
			if( menu_entry ) then
				INPUT_MENU_QUANTITY:SetText(menu_entry.quantity);
				local quantity = menu_entry.available_quantity;
				if(d_SelectedInputItem == g_SelectedInput.ITEM )then
					quantity = quantity+ g_SelectedInput.QUANTITY
				end
				INPUT_MENU_MAX_QUANTITY:SetText("/"..quantity);
			else
				INPUT_MENU_MAX_QUANTITY:SetText("/0");
				INPUT_MENU_QUANTITY:SetText("0");
			end
		end
	end
end

function OnSelectedItemEnter()
	if( d_SelectedInputItem ) then
		local item = d_SelectedInputItem;
		if (item and item.itemInfo) then
			ShowItemTooltip(item.itemInfo);
			System.PlaySound(SOUND_MOUSE_OVER);
			return
		end
	else
		ShowTooltip( Component.LookupText("CRAFTING_SELECT_RESOURCE_TT") );
	end
end

function OnUseResourceEnter()
	ShowTooltip( Component.LookupText("CRAFTING_PLACE_RESOURCE_TT") );
end

function OnUseResource()
	local new_quantity = tonumber(INPUT_MENU_QUANTITY:GetText());
	if( not d_SelectedInputItem) then
		UpdateInputInfo( g_SelectedInput, nil, 0 );
	elseif(g_SelectedInput.INPUT_REQ.unlimited) then
		if( new_quantity == 0 ) then
			UpdateInputInfo( g_SelectedInput, nil, 0 );
		else
			UpdateInputInfo( g_SelectedInput, d_SelectedInputItem, new_quantity );
		end
	else
		UpdateInputInfo( g_SelectedInput, d_SelectedInputItem );
	end
	PreviewItem();
	ShowManufactureBtn();
	HideMenu();
	d_SelectedInputItem = nil;
	System.PlaySound("Play_UI_Beep_20");
	g_SelectedInput = nil;
end

function OnQuantityChange()
	if( not g_SelectedInput ) then
		return;
	end
	local quantity = tonumber(INPUT_MENU_QUANTITY:GetText());
	local max_quantity = 0;
	if( d_SelectedInputItem ) then
		max_quantity = d_SelectedInputItem.available_quantity;
	end
	if( g_SelectedInput.ITEM == d_SelectedInputItem )then
		max_quantity = max_quantity + g_SelectedInput.QUANTITY;
	end

	function UpdateQuantity(value)
		if( quantity ~= value ) then
			INPUT_MENU_QUANTITY:SetText( value );
		end
	end
	if( d_SelectedInputItem ) then
		if( g_SelectedInput.MATERIALTYPE ~= 0 and (quantity < 0 or not d_SelectedInputItem.quantity)) then
			UpdateQuantity( 1 );
		elseif( quantity > max_quantity) then
			UpdateQuantity( max_quantity );
		end
	else
		UpdateQuantity( 0 );
	end
end

function OnQuantityFocus()
	RECIPES_RECIPEFILTER:ReleaseFocus();
end

function OnRecipeFilterFocus()
	INPUT_MENU_QUANTITY:ReleaseFocus();
end

function OnInputSelectAccept()
	local item_info, stack_info = INPUT_AMT_ENTRY:GetItemInfo();
	local INPUT = item_info.INPUT;
	if( stack_info.selected > 0 ) then
		UpdateInputInfo( INPUT, item_info.ITEM, stack_info.selected );
	else
		UpdateInputInfo( INPUT, nil, 0 );
	end
	PreviewItem();
	-- if able to craft all good ) 
	ShowManufactureBtn();
	
	INPUT_AMT_ENTRY:Destroy();
	INPUT_AMT_ENTRY = nil;
	INPUT_AMOUNTSELECTOR:Hide();
end

function OnInputSelectDecline()
	INPUT_AMT_ENTRY:Destroy();
	INPUT_AMT_ENTRY = nil;
	INPUT_AMOUNTSELECTOR:Hide();
end

function OnInputSlotEnter(arg)
	if( g_workbenchPreview ) then
		return;
	end
	local widget = arg.widget:GetParent();
	local INPUT = INPUT_ENTRIES[tonumber(widget:GetTag())];
	if (INPUT.INPUT_REQ) then
		System.PlaySound(SOUND_MOUSE_OVER);
		if (INPUT.INPUT_REQ.item_type ~= 0) then
			local recipe = CFT_FindRecipeForInput(INPUT, true);
			local text = ""
			if( recipe ) then
				text = Component.LookupText("CRAFTING_INPUT_CRAFT_TT").."\n"
			else
				text = Component.LookupText("CRAFTING_INPUT_FIND_TT").."\n"
			end
			
			local itemInfo = Game.GetItemInfoByType(INPUT.INPUT_REQ.item_type);
			ShowTooltip(text..itemInfo.name);
		else
			if (INPUT.ITEM and INPUT.ITEM.itemInfo) then
				itemInfo = INPUT.ITEM.itemInfo;
				ShowItemTooltip(itemInfo);
			else
				if (INPUT.INPUT_REQ.material_type ~= 0) then
					local itemTypes = {};
					local item_list = Component.LookupText("CRAFTING_INPUT_SELECT_TT").."\n";
					CFT_CollectItemTypesOfResourceType(INPUT.INPUT_REQ.material_type, itemTypes, d_current_recipe.attribute_map);
					local n = #itemTypes;
					for i,itemTypeId in ipairs(itemTypes) do
						local info = Game.GetItemInfoByType(itemTypeId);
						item_list = item_list.. info.name;
						if (i < n) then
							item_list = item_list.."\n";
						end
					end
					ShowTooltip(item_list);
				end
			end
		end
	end
end

function OnInputSlotLeave()
	HideTooltip();
end

function OnCreateInput()
	local INPUT = g_SelectedInput;
	local recipe = CFT_FindRecipeForInput(INPUT, true);
	SelectRecipe(recipe);
	g_SelectedInput = nil;
end

function OnCreateSelectedInput()
	local recipe = CFT_FindRecipeForInput(g_SelectedInput, true);
	if(recipe)then
		SelectRecipe(recipe);
	end
	HideMenu();
	g_SelectedInput = nil;
end

function OnClearSelectedInput()
	d_SelectedInputItem = menu_entry;
	OnUseResource();
end

function OnInputMenuScroll(args)
	--System.PlaySound("Play_SFX_NewYou_GearRackScroll");
	SetInputMenuOffset( g_InputMenuOffset + args.amount );
end

function CompMenuSlider_OnChange()
	local offset = math.floor(INPUT_MENU_SCROLL_BAR:GetPercent() * (#d_InputMenuItems - #w_InputMenuWidgets+1));	
	SetInputMenuOffset( offset )
end

-- RECIPE LIST EVENTS
function OnRecipeCertResponse( args, err)
	if( err ) then
		warn( tostring( err ) );
	end
	
	
	CFT_GLOBALS.g_recipe_certs = {};
	if( err ) then
		warn("Bad response on cert response.")
	else
		for _, certs in pairs( args ) do
			CFT_GLOBALS.g_recipe_certs[certs] = true;
		end
	end
		
	CFT_UpdateAvailibleRecipeList();
	FilterRecipes();
	DisplayRecipes();
end

function OnRecipeEnter(arg)
	--System.PlaySound(SOUND_MOUSE_OVER);
	-- JSU
	local itemTypeId = arg.widget:GetTag();
	local itemInfo = Game.GetItemInfoByType(itemTypeId);
	if (itemInfo) then
		ShowItemTooltip(itemInfo);
	else
		local widget = arg.widget:GetParent();
		local index = tonumber(widget:GetTag());
		local RCP = w_RecipeWidgets[index];
		if( RCP.RECIPE )then
			ShowTooltip(RCP.RECIPE.description);
		end
	end
end

function OnRecipeLeave()
	HideTooltip();
end

function OnRecipeSelect(args)
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	HideMenu();
	
	local widget = args.widget:GetParent();
	local index = tonumber(widget:GetTag());
	local RCP = w_RecipeWidgets[index];
	if( RCP.TREE ) then
		RCP.TREE.open = not RCP.TREE.open;
		if(RCP.TREE.open)then
			System.PlaySound("Play_UI_Beep_26");
		else
			System.PlaySound("Play_UI_Beep_27");
		end
		local offset = g_RecipeListOffest;
		--[[
		-- try to move the openned tree to the top of the recipe list
		if( RCP.TREE.open and index > (#w_RecipeWidgets - 3 ) ) then
			offset = offset + index;
		end
		--]]
		GenerateRecipeList();
		SetRecipeOffset( offset );
	elseif( RCP.RECIPE )then
		if( d_selected_recipe == RCP.RECIPE ) then
			return;
		else
			System.PlaySound("Play_UI_Beep_12");
			SelectRecipe( RCP.RECIPE );
		end
	end
end

function OnRecipeScroll(args)
	SetRecipeOffset( g_RecipeListOffest + args.amount );
end

function RecipeSlider_OnChange()
	local offset = math.floor(RECIPES_SCROLL_BAR:GetPercent() * (#CFT_GLOBALS.g_recipetree_as_list - #w_RecipeWidgets+1));		
	SetRecipeOffset( offset )
end

function OnWorkbenchScroll(args)
	SetWorkbenchOffset( g_WorkBenchListOffest + args.amount );
end

function WorkbenchSlider_OnChange()
	local offset = math.floor(WORKB_SCROLL_BAR:GetPercent() * (#d_workbenches - #w_WorkBenchWidgets+1));		
	SetWorkbenchOffset( offset )
end

function OnToggleCraftableEnter()
	if( CFT_GLOBALS.g_filter_craftable ) then
		ShowTooltip(Component.LookupText("CRAFTING_SHOW_ALL_RECIPES"));
	else
		ShowTooltip(Component.LookupText("CRAFTING_SHOW_CRAFTABLE"));
	end
end

function OnToggleCraftable()
	CFT_GLOBALS.g_filter_craftable = not CFT_GLOBALS.g_filter_craftable;
	OnToggleCraftableEnter();
	FilterRecipes();
end

function OnTrackEnter()
	ShowTooltip(Component.LookupText("CRAFTING_TRACK_TT"));
end

function OnTrackLeave()
	HideTooltip();
end

function OnTrack()
	if( Game.IsTrackingRecipe(d_selected_recipe.id) ) then
		UnTrack();
	else
		Track();
	end
end
	
function Track()
	if ( Game.AddRecipeToCart( d_selected_recipe.id ) ) then
		TRACK_BTN:Show();
		TRACK_BTN:SetTextKey("SHOPPING_CART_UNTRACK_RECIPE");
		System.PlaySound("Play_Vox_BattleframeVocal_Male01_ItemTrackingActivated");
	end
end

function UnTrack()
	Game.RemoveRecipeFromCart( d_selected_recipe.id );
	TRACK_BTN:Show();
	TRACK_BTN:SetTextKey("SHOPPING_CART_TRACK_RECIPE");
	System.PlaySound("Play_Vox_BattleframeVocal_Male01_ItemTrackingDeActivated");
end


function OnTutorialEnter()
	ShowTooltip(Component.LookupText("SHOW_TUTORIAL_VIDEO"));
end

function OnTutorial()
	Component.PostMessage("Mainframe:Main", "video", "crafting");
end

-- MANUFACTURE EVENTS
function OnManufactureEnter()
	System.PlaySound(SOUND_MOUSE_OVER);
	ShowTooltip(Component.LookupText("CRAFTING_MANUFACTURE_TT"));
end

function OnManufactureLeave()
	HideTooltip();
end

function OnManufactureRequest()
	MANUFACTURE_BTN:Hide();
	
	System.PlaySound("Play_SFX_WebUI_Equip_Battleframe");
	
	if( not d_current_recipe ) then
		warn("no selected recipe");
		return;
	end

	local workbench = FindEmptyWorkbench();	
	if( workbench == "purchase") then
		-- displaying a dialog
		g_unlock_req_via_manu = true;
		MANUFACTURE_BTN:Show();
		return;
	elseif( workbench == nil ) then
		warn("no empty workbenches");
		
		function close()
			MANUFACTURE_BTN:Show();
			ErrorDialog.Hide()
		end
		ErrorDialog.Display( Component.LookupText("CRAFTING_WB_FULL"), close );
		ErrorDialog.AddOption( {label=Component.LookupText("Close"), OnPress=close} );
		return;
	end
	
	local items = {}
	for c = 1, #INPUT_ENTRIES do
		local INPUT = INPUT_ENTRIES[c];
		local ITEM = INPUT.ITEM;
		if( INPUT.INPUT_REQ ) then
			if( ITEM ) then
				local item_info = {};
				item_info.item_sdb_id = ITEM.item_sdb_id;
				item_info.item_id = ITEM.item_id;
				item_info.resource_type = ITEM.resource_type;
				item_info.quantity = INPUT.QUANTITY;
				item_info.output_idx = INPUT.OUTPUT_IDX;
				items[INPUT.OUTPUT_IDX]= item_info;
			elseif( INPUT.OUTPUT_IDX ) then
				items[INPUT.OUTPUT_IDX]={output_idx = INPUT.OUTPUT_IDX, item_id=0, quantity=0, item_sdb_id=0};
			end
		end
	end
	
	table.sort(items, function(a,b)return a.output_idx < b.output_idx end)
	if( CFT_ManufactureRequest( d_selected_recipe.id, d_current_recipe.inputs, items, workbench.data.workbench_guid, ManufactureResponse, d_num_parallel_builds ) ) then
		PlayDialog( { "Play_ManufacturingStarted_01", "Play_ManufacturingStarted_02", "Play_ManufacturingStarted_03" } );
	end
end



function OnWBButtonEnter(args)
	local widget = args.widget:GetParent():GetParent();
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	local workbench = WB.BENCH;
	
	if( workbench.data.blueprint_id )then
		if( workbench.data.seconds_remaining > 0 ) then
			ShowTooltip(Component.LookupText("CRAFTING_WB_FINALIZE_TT", workbench.data.rb_complete_cost));
		else
			ShowTooltip(Component.LookupText("CRAFTING_CLAIM_ITEMS"));
		end
	else
		--ShowTooltip("Select Workbench");
	end
end

function OnWBButton(args)
	HideMenu();
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	WB_PURCHASEPROMPT:Close();
	local widget = args.widget;
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	local workbench = WB.BENCH;
	g_selected_workbench = workbench;
	if( workbench.unlock_cost and (workbench.vip)) then
		OnWBPurchase_Accept();
		System.PlaySound("Play_SFX_WebUI_Equip_BackpackModule");
	elseif( workbench.data.blueprint_id )then
		if( workbench.data.seconds_remaining > 0 ) then
			CRAFT_TIP:Hide();
			Wallet.PromptRedBeanSpend( workbench.data.rb_complete_cost, Component.LookupText("CRAFTING_WB_FINALIZE", workbench.data.rb_complete_cost), OnFinalizePurchase_Accept )
			System.PlaySound("Play_UI_Beep_10");
		else
			OnWBUnloadRequest(workbench);
			System.PlaySound("Play_UI_ARESMIssions_Pickup_Generic01");
		end
	end
	
	HideMenu();
end

-- WORKBENCH EVENTS
function OnWBCancelEnter()
	ShowTooltip(Component.LookupText("CRAFTING_WB_CANCEL"));
	System.PlaySound(SOUND_MOUSE_OVER);
end

function OnWBCancelLeave()
	HideTooltip();
end

function OnWBCancelRequest(args)
	-- force wait display to prevent double click

	local widget = args.widget:GetParent();
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	local workbench = WB.BENCH;
	
	local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..workbench.data.workbench_guid.."/cancel";		
	SendHTTPRequest(url, "POST", args, OnWBCancelRequestResponse );
	ShowMouseBlock();

	local recipe = CFT_FindRecipe(workbench.data.blueprint_id);
	if( recipe and recipe.unavailable ) then
		recipe.unavailable = false;
		GenerateRecipeList();
		DisplayRecipes();
	end

	if(g_workbenchPreview)then
		SelectRecipe(nil);
	end
	HideMenu();
	System.PlaySound("Play_UI_Beep_23");
end

function OnWBCancelRequestResponse(args, err)
	if( err ) then
		-- something went wrong when cancelling build request
		WebResponseFailure( err, Component.LookupText("CRAFTING_WB_CANCEL_ERR") );
		return;
	end
	
	UpdateWorkbench();
	UpdateInventory();
end

function OnWBUnloadRequest( workbench )
	-- force wait display to prevent double click
	HideMenu();
	local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..workbench.data.workbench_guid.."/unload";		
	SendHTTPRequest(url, "POST", args, OnWBUnloadRequestResponse );
	ShowMouseBlock();
	
	g_selected_workbench = nil
end

function OnWBUnloadRequestResponse(args, err)	
	if( err ) then
		-- something failed unloading
		-- the player will need to submit the unload request again
		WebResponseFailure( err, Component.LookupText("CRAFTING_UNLOAD_ERR") );
		return;
	end
	
	local recipe = CFT_GLOBALS.d_recipes[tostring(args.blueprint_id)];
	local research_recipe = false;
	local research_recipes = {};
	if( recipe and recipe.blueprint_type == 2 )then
		callback( function() WebCache.Request(CFT_CERT_UPDATE) end, nil, 0.2 );
		research_recipe = true;
		research_recipes = CFT_GetRecipesForResearch(recipe);
	end
		
	if( FRAME:IsVisible() ) then
		local combined_outputs = {};
		local best_item = nil;
		local research_recipes = {};
		if( not research_recipe ) then
			for _,output in pairs(args.output) do
				local id = output.item_sdb_id;
				if(output.quality)then
					id = id.."_"..output.quality
				end
				if( combined_outputs[id] )then
					if( combined_outputs[id].quantity and output.quantity) then
						combined_outputs[id].quantity = combined_outputs[id].quantity + output.quantity;
					elseif( combined_outputs[id].quantity )then
						combined_outputs[id].quantity = combined_outputs[id].quantity + 1;
					else
						combined_outputs[id].quantity = 2;
					end
				else
					combined_outputs[id] = output;
					
					if( not best_item ) then
						best_item = output;
					elseif( best_item.quality and output.quality )then
						if( output.quality > best_item.quality) then
							best_item = output;
						end
					elseif( output.quality )then
						best_item = output;
					end
				end
			end
		else
			research_recipes = CFT_GetRecipesForResearch(recipe);
		end
		local d_output = {};
		for _,output in pairs( combined_outputs ) do
			table.insert( d_output, output );
		end
		
		table.sort( d_output, function (a,b)
			if( a.item_sdb_id == 10 ) then
				return false;
			end
			if( b.item_sdb_id == 10 ) then
				return true;
			end
			return a.item_sdb_id < b.item_sdb_id;
		end);
				
		Component.GenerateEvent("MY_CFT_REWARD_DISPLAY", {output=tostring(d_output), best_item=tostring(best_item), blueprint_id = args.blueprint_id, research_recipes = tostring(research_recipes)});
		g_waiting_for_mark_complete = false;
		UpdatePleaseWait();
	
		FRAME:Hide();
		BG_FRAME:Hide();
		RIGHT_WING:Hide();
		LEFT_WING:Hide();
		HideMenu();
		HideRecipe();
		if(w_MODELS.MAIN)then
			if(w_MODELS.MAIN:IsValid())then
				w_MODELS.MAIN:Show(false);
			else
				w_MODELS.MAIN:Destroy();
				w_MODELS.MAIN = nil;
			end
		end
	end
	
	for i=1, #w_WorkBenchWidgets do
		local WB = w_WorkBenchWidgets[i];
		WB.PLATE.SCOBJ:Hide();
		if( WB.MODEL ) then
			if( not WB.MODEL:IsValid() ) then
				WB.MODEL:Destroy();
				WB.MODEL = nil;
			else
				WB.MODEL:Hide();
			end
		end
	end
	
	-- tutorial
	if (ScriptedTutorial.HasFlag("listen_Unload")) then
		ScriptedTutorial.DispatchEvent("OnWorkbenchUnload", args);
	end
	
	UpdateInventory();
	UpdateWorkbench(0.5);
end

function OnRewardScreenHide()
	FRAME:Show();
	BG_FRAME:Show();
	RIGHT_WING:Show();
	LEFT_WING:Show();
	DisplayWorkBenches();
	if( d_selected_recipe ) then
		w_MODELS.MAIN:Show(true);
	end
	
	SelectRecipe(d_selected_recipe);
	
	HideMouseBlock();
end

-- unlock/purchase a workbench
function OnWBPurchase_Accept( id )
	
	WB_PURCHASEPROMPT:Close();
	if( not id and g_selected_workbench) then
		id = g_selected_workbench.id;
	end
	if(not id)then
		error("Invalid workbench id");
	end

	local args = {position=id}
	local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches";		
	SendHTTPRequest(url, "POST", args, OnWBUnlockResponse, true );
	g_selected_workbench = nil;
	
	UpdatePleaseWait();
end

-- finalize/complete build order on a workbench
function OnFinalizePurchase_Accept( response )
	if( response ) then
		if( g_selected_workbench) then
			if( g_selected_workbench.data.seconds_remaining>0)then
				local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..g_selected_workbench.data.workbench_guid.."/mark_complete";		
				SendHTTPRequest(url, "POST", args, OnFinalizeRequestResponse );
						
				WB_PURCHASEPROMPT:Close();
				PlayDialog( { "Play_RedBean_ManufactureNow_01", "Play_RedBean_ManufactureNow_02", "Play_RedBean_ManufactureNow_03" } );
				g_waiting_for_mark_complete = true;
			else
				OnWBUnloadRequest(g_selected_workbench);
			end
			UpdatePleaseWait();
		else
			error( "Invalid Workbench!" )
		end
	end
	if( not d_selected_recipe)then
		CRAFT_TIP:Show();
	end
end

function OnFinalizeRequestResponse(args, err)
	if( err ) then
		-- purchase response failed
		WebResponseFailure( err, Component.LookupText("CRAFTING_FINALIZE_ERR") );
		return;
	end
	
	if( g_selected_workbench ) then
		callback( function(workbench)
						OnWBUnloadRequest(workbench);
					end, g_selected_workbench, 1 );
	else
		UpdateWorkbench();
	end
	g_selected_workbench = nil
end

function OnWBPurchase_Cancel()
	WB_PURCHASEPROMPT:Close();
	g_unlock_req_via_manu = false;
end

function OnWBUnlockResponse(args, err)
	if( err ) then
		-- failure to unlock a workbench
		WebResponseFailure( err, Component.LookupText("CRAFTING_WB_UNLOCK_ERR") );
		return;
	end
	UpdateWorkbench();
	g_manufacture_post_wb_update = true;
end

function OnEnterWorkbench(args)
	local widget = args.widget:GetParent();
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	WB.BG:SetParam("alpha", 0.125 );
end

function OnLeaveWorkbench(args)
	local widget = args.widget:GetParent();
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	WB.BG:SetParam("alpha", 0.0 );
end

function OnSelectWorkbench(args)
	local widget = args.widget:GetParent();
	-- determine if display cancel or unload
	local WB = w_WorkBenchWidgets[tonumber(widget:GetTag())];
	
	local bench = WB.BENCH;
	if( not bench.data.blueprint_id ) then
		SelectRecipe(nil);
		return;
	end
	g_PreviewItem = nil;
	g_workbenchPreview = WB;
	local recipe = CFT_FindRecipe(bench.data.blueprint_id);
	if( recipe ) then	
		HideInputs();
		d_selected_recipe = recipe;
		DisplayRecipes(); -- update highlight
		d_CompareItemCount = 0;
		d_compare_item_info = nil;
		
		CRAFTING_TIME:Hide(); -- update to display actual timer
		
		
		-- JSU
		if (not w_MODELS.MAIN or not w_MODELS.MAIN:IsValid()) then
			if (w_MODELS.MAIN) then
				w_MODELS.MAIN:Destroy();
				w_MODELS.MAIN = nil;
			end
			w_MODELS.MAIN = SinvironmentModel.Create();
		end
		w_MODELS.MAIN:LoadItemType(d_selected_recipe.id);
		w_MODELS.MAIN:GetAnchor():SetParam("translation", {x=0, y=0, z=3.1});
		w_MODELS.MAIN:Normalize(.75);
		w_MODELS.MAIN:AutoSpin(.15);
		w_MODELS.MAIN:Show(true);
		
		SetScrollText(d_selected_recipe.description, DESCRIPTION_TEXT, DESCRIPTION_SCROLL, DESC_ROW);
		
		ITEM_NAME:SetText( d_selected_recipe.name );
		local text_dims = ITEM_NAME:GetTextDims();
		ITEM_NAME_BG:SetDims( "height:"..text_dims.height.."; width:"..text_dims.width);
		
		d_current_recipe = Game.GetRecipe( d_selected_recipe.id );
		UpdateParallelBuildCount( 1 );
		
		if( d_current_recipe.max_parallel > 1 )  then
			NUM_PARALLEL_SLIDER:Hide()
			NUM_PARALLEL:Show();
		else
			NUM_PARALLEL:Hide();
		end
		
		local index = 1;
		local INPUT_ENTRY = INPUT_ENTRIES[index];
		for i, input in pairs(d_current_recipe.inputs) do
			if ( input.material_type ~= 0 ) then
				INPUT_ENTRY.MATERIALTYPE = input.material_type;
				INPUT_ENTRY.INPUT_REQ = input;
				local ITEM = bench.data.inputs[tostring(i-1)][1];
				if( ITEM ) then
					ITEM.root_info = Game.GetRootItemInfo(ITEM.item_type);
					ITEM.itemInfo = Game.GetItemInfoByType( ITEM.item_sdb_id, ITEM.attribute_modifiers );
									
					ITEM.item_sdb_id = ITEM.root_info.sdb_id
					
					local name = input.material_type;
					INPUT_ENTRY.OUTPUT_IDX = input.output_index;
					INPUT_ENTRY.GROUP:Show();
					UpdateInputInfo( INPUT_ENTRY, ITEM, ITEM.quantity )
				else
					UpdateInputInfo( INPUT_ENTRY, nil, 0 )
				end
											
				index = index + 1;
				INPUT_ENTRY = INPUT_ENTRIES[index];
			end
		end
		for i, input in pairs(d_current_recipe.inputs) do
			local found = false;
			local ITEM = bench.data.inputs[tostring(i-1)][1];
			if ( input.item_type ~= 0 ) then
				ITEM.root_info = Game.GetRootItemInfo(input.item_type);
				ITEM.itemInfo = Game.GetItemInfoByType( ITEM.item_sdb_id, ITEM.attribute_modifiers );
				
				INPUT_ENTRY.GROUP:Show();
				INPUT_ENTRY.ITEMTYPE = input.item_type;
				INPUT_ENTRY.UNLIMITED = input.unlimited;
				INPUT_ENTRY.INPUT_REQ = input;
				UpdateInputInfo( INPUT_ENTRY, ITEM, ITEM[1].quantity )		
				INPUT_ENTRY.OUTPUT_IDX = input.output_index;
				INPUT_ENTRY.GROUP:Show();
			end
			index = index + 1;
			INPUT_ENTRY = INPUT_ENTRIES[index];
		end
		
		d_CompareItemCount = DisplayCompare();
		if( d_CompareItemCount > 0 ) then
			COMPARE_GROUP:Show();
		end
		PreviewItem();
	end
	
	MANUFACTURE_BTN:Hide();
	
end

-- COMPARE EVENTS
function OnCompare()
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	if( current_menu ~= COMPARE_MENU ) then
		HideMenu();
	else
		HideMenu();
		return;
	end
		
	g_CompareOffset = 0;
	d_compare_item_info = nil;
	TextFormat.Clear(COMPARE_MENU_TEXT);
	COMPARE_MENU_TEXT:SetTextColor("#FFFFFF");
	COMPARE_MENU_TEXT:SetTextKey("CRAFTING_NOTHING");
	if( not d_selected_recipe ) then
		return;
	end
	
	if( d_selected_recipe.outputs ) then
		DisplayStats();
		d_CompareItemCount = DisplayCompare();
		if( d_CompareItemCount > 0 ) then
			COMPARE_MENU:Show();
			current_menu = COMPARE_MENU;
		end
	end
end

function OnCompareSlotEnter(args)
	local widget = args.widget:GetParent();
	local index = widget:GetTag();
	local compare_widget = w_CompareWidgets[tonumber(index)];
	local ITEM = compare_widget.ITEM;
	if (ITEM and ITEM.itemInfo) then
		local attri_table = {}
		if( ITEM.attribute_modifiers )then
			for i, v in pairs( ITEM.attribute_modifiers ) do
				table.insert(attri_table, {id=tonumber(i), value=v} );
			end
		end
		local info = Game.GetPreviewItemInfo(ITEM, attri_table);
		ShowItemTooltip(info, g_PreviewItem);
	end
end

function OnCompareSlotSelect(args)
	RECIPES_RECIPEFILTER:ReleaseFocus();
	INPUT_MENU_QUANTITY:ReleaseFocus();
	
	HideMenu();

	local widget = args.widget:GetParent();
	local index = widget:GetTag();
	local compare_widget = w_CompareWidgets[tonumber(index)];
	local ITEM = compare_widget.ITEM;
	
	d_compare_item_info = ITEM;
	
	DisplayStats();
	local TF = TextFormat.Create();
	TF:Concat( LIB_ITEMS.GetNameTextFormat(ITEM.root_info, {quantity = ITEM.quantity, quality = ITEM.quality}));
	TF:ApplyTo( COMPARE_MENU_TEXT );
	HideMenu();
end

function OnCompareScroll(args)
	--System.PlaySound("Play_SFX_NewYou_GearRackScroll");
	g_CompareOffset =  g_CompareOffset + args.amount;
	g_CompareOffset =  math.max(0, math.min( g_CompareOffset, (d_CompareItemCount - #w_CompareWidgets) ) );
	DisplayCompare();
end

-- REFINE

function OnRefineEnter()
	ShowTooltip( Component.LookupText("CRAFTING_REFINE_TT"));
	REFINE_BUTTON:ParamTo( "exposure", 1, 0.1 );
end

function OnBattleframeEnter()
	ShowTooltip( Component.LookupText("CRAFTING_BATTLEFRAME_TT"));
	REFINE_BUTTON:ParamTo( "exposure", 1, 0.1 );
end

function OnResearchEnter()
	ShowTooltip( Component.LookupText("CRAFTING_RESEARCH_TT"));
	REFINE_BUTTON:ParamTo( "exposure", 1, 0.1 );
end

function OnButtonLeave()
	HideTooltip();
	REFINE_BUTTON:ParamTo( "exposure", 0.0, 0.1 );
end

function OnRefineRecipes()
	if( d_recipe_list_id == BLUEPRINT_REFINE_ID)then
		return;
	end
	d_recipe_list_id = BLUEPRINT_REFINE_ID;
	
	REFINE_BUTTON:Enable(false);
	BATTLEFRAME_BUTTON:Enable(true);
	RESEARCH_BUTTON:Enable(true);
	
	g_RecipeListOffest = 0;
	GenerateRecipeList();
	DisplayRecipes();
end

function OnBattleframeRecipes()
	if( d_recipe_list_id == BLUEPRINT_BUILD_ID)then
		return;
	end
	d_recipe_list_id = BLUEPRINT_BUILD_ID;
	
	REFINE_BUTTON:Enable(true);
	BATTLEFRAME_BUTTON:Enable(false);
	RESEARCH_BUTTON:Enable(true);
	
	g_RecipeListOffest = 0;
	GenerateRecipeList();
	DisplayRecipes();
end

function OnResearchRecipes()
	if( d_recipe_list_id == BLUEPRINT_RESEARCH_ID)then
		return;
	end
	d_recipe_list_id = BLUEPRINT_RESEARCH_ID;
	
	REFINE_BUTTON:Enable(true);
	BATTLEFRAME_BUTTON:Enable(true);
	RESEARCH_BUTTON:Enable(false);
	
	g_RecipeListOffest = 0;
	GenerateRecipeList();
	DisplayRecipes();
end

-- OUTPUT
function OnOutputPreviewEnter()
	if( g_PreviewItem and #g_PreviewItem.description > 0 )then
		ShowTooltip(g_PreviewItem.description);
	end
end

function OnOutputPreviewScroll(args)
	SetOutputPreviewOffset( g_OutputPreviewOffset + args.amount );
end

function OutputPreivewSlider_OnChange()
	local offset = math.floor(OUTPUT_PREVIEW_SCROLLBAR:GetPercent() * (#g_PreviewItems - #w_OutputPreviews+1));	
	SetOutputPreviewOffset( offset )
end

function SetOutputPreviewOffset( offset )
	local old_offset = g_OutputPreviewOffset;
	g_OutputPreviewOffset = math.max(0, math.min( offset, (#g_PreviewItems - #w_OutputPreviews) ) );
	
	if( (#g_PreviewItems - #w_OutputPreviews) <= 0 ) then
		OUTPUT_PREVIEW_SCROLLBAR:Hide();
	else
		OUTPUT_PREVIEW_SCROLLBAR:Show();
		OUTPUT_PREVIEW_SCROLLBAR:SetPercent( g_OutputPreviewOffset/(#g_PreviewItems - #w_OutputPreviews) )
	end
	
	if( old_offset ~= g_OutputPreviewOffset ) then
		DisplayOutputPreview();
	end
end

function OnOutputPreviewEnter2(arg)
	System.PlaySound(SOUND_MOUSE_OVER);

	local widget = arg.widget:GetParent();
	local OP = w_OutputPreviews[tonumber(widget:GetTag())];
	if( OP.OUTPUT and #OP.OUTPUT.description > 0 )then
		ShowTooltip(OP.OUTPUT.description);
	end
end

-- FUNCTIONS
function Toggle()
	if( FRAME:IsVisible() ) then
		OnClose();
	else
		OnOpen()
	end
end

function OnHideMenu()
	System.PlaySound("Play_UI_Beep_08");
	HideMenu();
end

function HideMenu()
	if( current_menu ) then
		if( current_menu.Close ) then
			current_menu:Close();
		else
			current_menu:Hide();
		end
		current_menu = nil;
		
		if( g_SelectedInput ) then
			UpdateInputInfo( g_SelectedInput, g_SelectedInput.ITEM, g_SelectedInput.QUANTITY );

			g_SelectedInput = nil;
		end
		
	end
end

function ResolutionUpdate()
	-- empty any previous children
	FinalizeWidgets( w_RecipeWidgets ); w_RecipeWidgets={};
	FinalizeWidgets( w_WorkBenchWidgets ); w_WorkBenchWidgets={};
	FinalizeWidgets( w_InputMenuWidgets ); w_InputMenuWidgets={};
	FinalizeWidgets( w_CompareWidgets ); w_CompareWidgets={};
	FinalizeWidgets( w_OutputPreviews ); w_OutputPreviews={};
	if( w_MODELS.OUTPUT ) then
		w_MODELS.OUTPUT:Destroy();
		w_MODELS.OUTPUT = nil
	end
	if( w_MODELS.OUTPUT_PLATE ) then
		Component.RemoveSceneObject(w_MODELS.OUTPUT_PLATE);
	end
	
	-- right wing
	local recipe_list_bounds = RECIPE_LIST:GetBounds();
	local num_recipes = math.max(recipe_list_bounds.height/(RECIPE_ENTRY_HEIGHT+4), 1 );
	local RCP;
	for i=1, num_recipes do
		RCP = {GROUP=Component.CreateWidget("recipe_entry", RECIPE_LIST)}
		RCP.GROUP:SetDims("height:"..RECIPE_ENTRY_HEIGHT.."; width:100%");
		RCP.NAME = RCP.GROUP:GetChild("name");
		RCP.NAME:SetText("")
		table.insert(w_RecipeWidgets, RCP);
		RCP.GROUP:SetTag(#w_RecipeWidgets);
		RCP.BORDER = RCP.GROUP:GetChild("border");
		RCP.HIGHLIGHT = RCP.GROUP:GetChild("highlight");
		RCP.FOCUS = RCP.GROUP:GetChild("focus");
	end	
	
	g_WorkBenchListOffest = 0;
	local wb_list_bounds = WORKB_LIST:GetBounds();
	local num_wb = math.max(wb_list_bounds.height/WORKBENCH_ENTRY_HEIGHT,1);
	local WB;
	local right_anchor = RIGHT_WING:GetAnchor();
	for i=1, num_wb do
		WB = {GROUP=Component.CreateWidget("workbench_slot", WORKB_LIST)}
		WB.GROUP:SetDims("height:"..WORKBENCH_ENTRY_HEIGHT.."; width:100%");
		WB.BG = WB.GROUP:GetChild("bg");
		WB.NAME = WB.GROUP:GetChild("name");
		WB.NAME:SetText("")
		WB.PROGRESS_BG = WB.GROUP:GetChild("progress_bg");
		WB.PROGRESS_MASK = WB.PROGRESS_BG:GetChild("progress_mask");
		WB.TIMER = WB.GROUP:GetChild("timer");
		WB.TIME_TEXT = WB.GROUP:GetChild("time_text");

		table.insert( w_WorkBenchWidgets, WB );
		local tag_value = #w_WorkBenchWidgets;
		WB.GROUP:SetTag(tag_value);
		WB.GROUP:Hide();
		
		WB.BUILD_COMPLETE = false;
		
		WB.CANCEL = WB.GROUP:GetChild("cancel");
		WB.CANCEL:SetTag(tag_value);
		WB.BUTTON = Button.Create(WB.GROUP:GetChild("button"));
		WB.BUTTON:AddHandler( "OnMouseDown", OnWBButton );
		WB.BUTTON:AddHandler( "OnMouseEnter", OnWBButtonEnter );
		WB.BUTTON:AddHandler( "OnMouseLeave", HideTooltip );
		WB.BUTTON:SetTag(tag_value);
		WB.RB_BUTTON =  WB.GROUP:GetChild("rb_icon");
		WB.RB_TEXT =  WB.RB_BUTTON:GetChild("text");
		WB.ANCHOR = WB.GROUP:GetChild("anchor");
		WB.ANCHOR:SetTag( tostring(i) );
		WB.ANCHOR:ScaleToBounds(true);
		
		WB.PLATE = {SCOBJ=Component.CreateSceneObject("GUI_Icon_Plate_001")};
		WB.PLATE.ANCHOR = WB.PLATE.SCOBJ:GetAnchor();
		WB.PLATE.ANCHOR:SetParent(WB.ANCHOR:GetAnchor());
		--WB.PLATE.ANCHOR:SetParent(WB.ANCHOR);
		--WB.PLATE.ANCHOR:SetParam("translation", {x=0,y=0,z=0} );
		--WB.PLATE.ANCHOR:SetParam("scale", {x=0.5,y=0.5,z=0.5});
		--WB.PLATE.ANCHOR:SetParam("rotation", {axis={x=1,y=0,z=0}, angle=80} );
		WB.PLATE.SCOBJ:SetParam("tint", "#247CBD");
		WB.PLATE.SCOBJ:SetParam("alpha", 0.2);
		WB.PLATE.SCOBJ:SetAutoScale("fit");
		WB.PLATE.SCOBJ:Hide();
		
		WB.VIP = WB.GROUP:GetChild("VIP");
		
		WB.MODEL = nil;
	end
	
	-- input selection menu
	local cm_list_bounds = INPUT_MENU_LIST:GetBounds();
	local num_CM = math.max(cm_list_bounds.height/INPUT_MENU_ENTRY_HEIGHT,1);
	local CM;
	for i=1, num_CM do
		CM = {GROUP=Component.CreateWidget("input_menu_item", INPUT_MENU_LIST)}
		CM.GROUP:SetDims("height:"..INPUT_MENU_ENTRY_HEIGHT.."; width:100%");
		CM.NAME = CM.GROUP:GetChild("name");
		CM.STAT = CM.GROUP:GetChild("stat");
		CM.QUANTITY = CM.GROUP:GetChild("quantity");
		CM.NAME_BG = CM.GROUP:GetChild("name_bg");
		CM.STAT_BG = CM.GROUP:GetChild("stat_bg");
		CM.QUANTITY_BG = CM.GROUP:GetChild("quantity_bg");
		CM.BG = CM.GROUP:GetChild("bg");
		table.insert(w_InputMenuWidgets, CM);
		CM.GROUP:SetTag(#w_InputMenuWidgets);
	end	
	
	-- left wing
	
	local compare_list_bounds = COMPARE_MENU_LIST:GetBounds();
	local num_compare = math.max(compare_list_bounds.height/COMPARE_ENTRY_HEIGHT, 1 );
	local CMP;
	for i=1, num_compare do
		CMP = {GROUP=Component.CreateWidget("compare_slot", COMPARE_MENU_LIST)}
		CMP.GROUP:SetDims("height:"..COMPARE_ENTRY_HEIGHT.."; width:100%");
		CMP.TEXT = CMP.GROUP:GetChild("text");
		table.insert(w_CompareWidgets, CMP);
		CMP.GROUP:SetTag(#w_CompareWidgets);
	end	
	
	if( FRAME:IsVisible() )then
		DisplayRecipes();
		DisplayInputsMenu( );
		DisplayWorkBenches();
		HideMenu();
	end
		
	local left_anchor = LEFT_WING:GetAnchor();
	w_MODELS.OUTPUT_PLATE = Component.CreateSceneObject("GUI_Icon_Plate_001");
	w_MODELS.OUTPUT_PLATE:GetAnchor():SetParent(left_anchor);
	w_MODELS.OUTPUT_PLATE:GetAnchor():SetParam("translation", {x=-.3, y=1, z=5.1/g_screen_ratio});
	w_MODELS.OUTPUT_PLATE:GetAnchor():SetParam("scale", {x=3, y=3, z=3});
	w_MODELS.OUTPUT_PLATE:SetParam("tint", "#006F00");
	w_MODELS.OUTPUT_PLATE:SetParam("alpha", 1);
	w_MODELS.OUTPUT_PLATE:Hide()
	
	local output_list_bounds = OUTPUT_PREVIEW:GetBounds();
	local num_op = math.max(output_list_bounds.height/OUTPUT_ENTRY_HEIGHT,1);
	local OP;
	local left_anchor = LEFT_WING:GetAnchor();
	for i=1, num_op do
		OP = {GROUP=Component.CreateWidget("output_slot", OUTPUT_PREVIEW_LIST)}
		OP.GROUP:SetDims("height:"..OUTPUT_ENTRY_HEIGHT.."; width:100%");		
		OP.TEXT = OP.GROUP:GetChild("text");
		OP.QUALTIY = OP.GROUP:GetChild("quality");
		OP.QUANTITY = OP.GROUP:GetChild("quantity");

		table.insert( w_OutputPreviews, OP );
		local tag_value = #w_OutputPreviews;
		OP.GROUP:SetTag(tag_value);
		OP.GROUP:Hide();
		
		OP.ANCHOR = Component.CreateAnchor();
		OP.ANCHOR:SetScene("sinvironment")
		OP.ANCHOR:SetParent( left_anchor );
		OP.ANCHOR:SetParam("translation", {x=-.3,y=0,z=(4.9/g_screen_ratio-1.60*(i-1))} )
		OP.ANCHOR:SetParam("scale", {x=2.9,y=2.9,z=2.9});
		
		OP.PLATE = {SCOBJ=Component.CreateSceneObject("GUI_Icon_Plate_001")};
		OP.PLATE.ANCHOR = OP.PLATE.SCOBJ:GetAnchor();
		OP.PLATE.ANCHOR:SetParent(OP.ANCHOR);
		OP.PLATE.ANCHOR:SetParam("translation", {x=0,y=0,z=0} );
		--OP.PLATE.ANCHOR:SetParam("scale", {x=0.5,y=0.5,z=0.5});
		OP.PLATE.SCOBJ:SetParam("tint", "#006F00");
		OP.PLATE.SCOBJ:SetParam("alpha", 0.2);
		OP.PLATE.SCOBJ:Hide();
		
		OP.MODEL = nil;
		
		local FOCUS = OP.GROUP:GetChild("focus");
		FOCUS:BindEvent("OnScroll", OnOutputPreviewScroll );
		FOCUS:BindEvent("OnMouseEnter", OnOutputPreviewEnter2 );
		FOCUS:BindEvent("OnMouseLeave", HideTooltip);
	end	
	OUTPUT_PREVIEW:SetDims( "right:_; top:_; width:_height:"..num_op * OUTPUT_ENTRY_HEIGHT );
	
	local desc_bounds = DESCRIPTION_GROUP:GetBounds();
	DESCRIPTION_SCROLL:UpdateSize(desc_bounds);
	DESCRIPTION_TEXT:SetDims("width:"..desc_bounds.width);
	SetScrollText( DESCRIPTION_TEXT:GetText(), DESCRIPTION_TEXT, DESCRIPTION_SCROLL, DESC_ROW );
	
	g_resolution_dirty = false;
end

-- RECIPE LIST FUCNTIONS
function FilterRecipes()
	CFT_GLOBALS.g_recipe_filter = normalize(RECIPES_RECIPEFILTER:GetText());
	SetRecipeOffset( 0 );
	d_filtered_recipes = {};
	local recipes = {};
	if( #CFT_GLOBALS.g_recipe_filter > 0 ) then
		for _,recipe in pairs(CFT_GLOBALS.d_available_recipes) do
			if( string.find(normalize(recipe.name), CFT_GLOBALS.g_recipe_filter) ~= nil )then
				table.insert(recipes, recipe);
			end
		end
	else
		recipes = CFT_GLOBALS.d_available_recipes;
	end
		
	if( CFT_GLOBALS.g_filter_craftable ) then
		for _,recipe in pairs(recipes) do
			if( CFT_CanCraft(recipe.id, d_inventory) ) then
				table.insert(d_filtered_recipes, recipe);
			end
		end
	else
		for _,recipe in pairs(recipes) do
			table.insert(d_filtered_recipes, recipe);
		end
	end
	
	UpdateRecipeTables();
	DisplayRecipes();
end

function UpdateRecipeTables()
	-- empty the recipe table
	for i,v in pairs(CFT_GLOBALS.d_recipe_tables) do
		CFT_GLOBALS.d_recipe_tables[i] = {};
	end
		
	for _,recipe in pairs(d_filtered_recipes) do
		if(not recipe.item_subtype or not CFT_GLOBALS.d_recipe_tables[tonumber(recipe.item_subtype)] )then
			table.insert( CFT_GLOBALS.d_recipe_tables[0], recipe); -- dump into Misc. category
		else
			table.insert( CFT_GLOBALS.d_recipe_tables[recipe.item_subtype], recipe);
		end
	end
	
	for i,v in pairs(CFT_GLOBALS.d_recipe_tables) do
		table.sort(v, function(a, b) return a.name < b.name end)
	end	

	CFT_UpdateRecipeTreeCounts( d_recipe_tree );
	GenerateRecipeList();
end

function GenerateRecipeList()
	local expand_all = false;
	-- expose the entire tree when 
	if( d_recipe_tree.count ) then
		expand_all = #d_filtered_recipes <= (2 * #w_RecipeWidgets);
	end
	
	local tree = d_recipe_tree;
	if( d_recipe_list_id )then
		for _,child in pairs(d_recipe_tree.children) do
			if( child.id == d_recipe_list_id )then
				tree = child;
			end
		end
	end
	local prefix = "";
	CFT_GLOBALS.g_recipetree_as_list = {};
	local text_widget = nil;
	if(w_RecipeWidgets and #w_RecipeWidgets > 0 )then
		text_widget = w_RecipeWidgets[1].NAME;
	end
	for _,data in pairs(tree.children) do
		CFT_GenerateList( data, text_widget, "", expand_all );
	end
		
	-- insert root's recipes
	CFT_AddRecipesToList( CFT_GLOBALS.d_recipe_tables[tree.id] );
	
	if( #CFT_GLOBALS.g_recipetree_as_list <= 0 or #CFT_GLOBALS.g_recipetree_as_list < #w_RecipeWidgets ) then
		RECIPES_SCROLL_BAR:Hide();
	else
		RECIPES_SCROLL_BAR:Show();
		RECIPES_SCROLL_BAR:SetParam( "thumbsize", #w_RecipeWidgets/#CFT_GLOBALS.g_recipetree_as_list );
		RECIPES_SCROLL_BAR:SetScrollSteps( #CFT_GLOBALS.g_recipetree_as_list - #w_RecipeWidgets );
	end
end

function HideInputs()
	for _,INPUT in pairs(INPUT_ENTRIES) do
		if( INPUT.ITEM ) then
			if( INPUT.ITEM ~= ITEM and INPUT.ITEM.available_quantity) then
				INPUT.ITEM.available_quantity = INPUT.ITEM.available_quantity + INPUT.QUANTITY;
				-- check that we go over the item quanitity
				if( INPUT.ITEM.available_quantity > INPUT.ITEM.quantity ) then
					warn("Adding back more than available!")
					INPUT.ITEM.available_quantity = INPUT.ITEM.quantity;
				end
				INPUT.QUANTITY = 0;
			end
		end
		
		INPUT.ITEM = nil;
		INPUT.INPUT_REQ = nil;
		INPUT.MATERIALTYPE = 0;
		INPUT.ITEMTYPE = 0;
		INPUT.GROUP:Hide();
		INPUT.QUANTITY_LOW = true;
		INPUT.QUANTITY  = 0;
		INPUT.GROUP:Hide();
		
		if( INPUT.PLATE ) then
			Component.RemoveSceneObject(INPUT.PLATE.SCOBJ);
			INPUT.PLATE = nil;
		end
		
		local SINMODEL = w_MODELS.SUBCOMPONENTS[INPUT];
		if (SINMODEL and SINMODEL:IsValid()) then
			SINMODEL:Unload();
		end
	end
end

function HideRecipe()
	g_workbenchPreview = nil;
	HideMenu();
	HideInputs();

	d_CompareItemCount = 0;
	d_compare_item_info = nil;
	COMPARE_GROUP:Hide();
	TextFormat.Clear(COMPARE_MENU_TEXT);
	COMPARE_MENU_TEXT:SetTextColor("#FFFFFF");
	COMPARE_MENU_TEXT:SetTextKey("CRAFTING_NOTHING");

	CRAFTING_TIME:Hide();
	
	STATS:Hide();
	COMPARE_GROUP:Hide();
	DESCRIPTION:Hide();
	OUTPUT_PREVIEW:Hide();
	OUTPUT:Hide();
	
	for _,requirement in pairs(w_RequirementIcons) do
		Component.RemoveWidget(requirement.GROUP);
	end
	w_RequirementIcons = {};
	
	HidePreviewDisplay();
	
	COMPONENT_TIP:Hide();
	
	if( not d_selected_recipe or hide ) then
		SetScrollText("", DESCRIPTION_TEXT, DESCRIPTION_SCROLL, DESC_ROW);
		d_current_recipe = nil;
		ITEM_NAME:SetText("");
		MANUFACTURE_BTN:Hide();
		TRACK_BTN:Hide();
		d_Stats = {};
		DisplayStats();
		if( w_MODELS.MAIN and w_MODELS.MAIN:IsValid()) then
			w_MODELS.MAIN:Hide();
		end
		NUM_PARALLEL:Hide();
		INPUTS.GROUP:Hide();
		CRAFT_TIP:Show();
		return;
	end
end

function SelectRecipe(recipe)
	g_workbenchPreview = nil;
	HideMenu();
	HideInputs();

	d_selected_recipe = recipe;
		
	if( not d_selected_recipe and d_tutorial_recipe) then
		d_selected_recipe = CFT_FindRecipe(d_tutorial_recipe);
	end
	
	if (d_selected_recipe and ScriptedTutorial.HasFlag("listen_RecipeSelect")) then
		ScriptedTutorial.DispatchEvent("SelectRecipe", { id = d_selected_recipe.id });
	end
	
	DisplayRecipes(); -- update highlight
	d_CompareItemCount = 0;
	d_compare_item_info = nil;
	COMPARE_GROUP:Hide();
	TextFormat.Clear(COMPARE_MENU_TEXT);
	COMPARE_MENU_TEXT:SetTextColor("#FFFFFF");
	COMPARE_MENU_TEXT:SetTextKey("CRAFTING_NOTHING");

	CRAFTING_TIME:Hide();
	
	STATS:Hide();
	COMPARE_GROUP:Hide();
	DESCRIPTION:Hide();
	OUTPUT_PREVIEW:Hide();
	OUTPUT:Hide();
	
	for _,requirement in pairs(w_RequirementIcons) do
		Component.RemoveWidget(requirement.GROUP);
	end
	w_RequirementIcons = {};
	
	HidePreviewDisplay();
	
	COMPONENT_TIP:Hide();
	
	if( not d_selected_recipe ) then
		SetScrollText("", DESCRIPTION_TEXT, DESCRIPTION_SCROLL, DESC_ROW);
		d_current_recipe = nil;
		ITEM_NAME:SetText("");
		MANUFACTURE_BTN:Hide();
		TRACK_BTN:Hide();
		d_Stats = {};
		DisplayStats();
		if( w_MODELS.MAIN and w_MODELS.MAIN:IsValid()) then
			w_MODELS.MAIN:Hide();
		end
		NUM_PARALLEL:Hide();
		INPUTS.GROUP:Hide();
		CRAFT_TIP:Show();
		return;
	end
	
	CRAFT_TIP:Hide();
	
	if( d_selected_recipe and Game.CanTrackRecipe(d_selected_recipe.id) ) then
		if( Game.IsTrackingRecipe(d_selected_recipe.id) ) then -- if the current recipe is already tracked, show the untrack button.
			TRACK_BTN:Show();
			TRACK_BTN:SetTextKey("SHOPPING_CART_UNTRACK_RECIPE");
		else
			TRACK_BTN:Show();
			TRACK_BTN:SetTextKey("SHOPPING_CART_TRACK_RECIPE");
		end
	else
		-- Grey out the tracking button. Hiding all buttons for now.
		TRACK_BTN:Hide();
	end
	
	SetScrollText(d_selected_recipe.description, DESCRIPTION_TEXT, DESCRIPTION_SCROLL, DESC_ROW);
	
	d_CompareItemCount = DisplayCompare();
	if( d_CompareItemCount > 0 ) then
		COMPARE_GROUP:Show();
	end
	
	-- JSU
	if (not w_MODELS.MAIN or not w_MODELS.MAIN:IsValid()) then
		if (w_MODELS.MAIN) then
			w_MODELS.MAIN:Destroy();
		end
		w_MODELS.MAIN = SinvironmentModel.Create();
	end

	local idx, item = next(d_selected_recipe.outputs );
	if( item ) then
		w_MODELS.MAIN:LoadItemType(item.item_id);
	else
		w_MODELS.MAIN:LoadItemType(d_selected_recipe.id);
	end
	w_MODELS.MAIN:GetAnchor():SetParam("translation", {x=0, y=0, z=3.1});
	w_MODELS.MAIN:Normalize(.75);
	w_MODELS.MAIN:AutoSpin(.15);
	w_MODELS.MAIN:Show(true);
	
	--[[
	local g_SHD_PARAM;

	if( w_MODELS.MAIN ) then
		Sinvironment.SetModelMaterialOverride(w_MODELS.MAIN.HANDLE); -- Sets this to be overriden 
		g_SHD_PARAM = Sinvironment.GetModelShaderParamID(w_MODELS.MAIN.HANDLE, "HologramLerpObjSpace");   -- Gets handle of param
		Sinvironment.SetModelShaderParam(w_MODELS.MAIN.HANDLE, g_SHD_PARAM, 0);                           -- Sets value of param
		Sinvironment.ShaderParamModelTo(w_MODELS.MAIN.HANDLE, g_SHD_PARAM, 1, 10);                        -- Lerps param to new value in time (works like paramTo)
	end
	--]]
	
	ITEM_NAME:SetText( d_selected_recipe.name );	
	
	-- populate the components
	MANUFACTURE_BTN:Show();

	d_current_recipe = Game.GetRecipe( d_selected_recipe.id );
	UpdateParallelBuildCount( 1 );
	if( d_current_recipe.max_parallel > 1 )  then
		NUM_PARALLEL_SLIDER:Show()
		NUM_PARALLEL_SLIDER:SetScrollSteps(d_current_recipe.max_parallel-1);
		NUM_PARALLEL_SLIDER:SetJumpSteps(4);
		local bounds = NUM_PARALLEL_SLIDER:GetBounds();
		NUM_PARALLEL_SLIDER:SetParam("thumbsize", math.max(.1, 1 / d_current_recipe.max_parallel));
		NUM_PARALLEL:Show();
	else
		NUM_PARALLEL:Hide();
	end
	
	INPUTS.GROUP:Show();
	local index = 1;
	local INPUT_ENTRY = INPUT_ENTRIES[index];
	for _, input in pairs(d_current_recipe.inputs) do
		if ( input.material_type ~= 0 ) then
			local name = input.material_type;
			INPUT_ENTRY.GROUP:Show();
			INPUT_ENTRY.MATERIALTYPE = input.material_type;
			INPUT_ENTRY.INPUT_REQ = input;
			INPUT_ENTRY.OUTPUT_IDX = input.output_index;
			
			UpdateInputInfo( INPUT_ENTRY, nil )
			local items = FindItemsForInput(INPUT_ENTRY);
			if( #items == 1 ) then
				UpdateInputInfo( INPUT_ENTRY, items[1].item, items[1].item.available_quantity )
			end
			MANUFACTURE_BTN:Hide();
									
			index = index + 1;
			INPUT_ENTRY = INPUT_ENTRIES[index];
		end
	end
	
	for _, input in pairs(d_current_recipe.inputs) do
		local found = false;
		local ITEM = {};
		if ( input.item_type ~= 0 ) then
			ITEM.root_info = Game.GetRootItemInfo(input.item_type);
			ITEM.itemInfo = Game.GetItemInfoByType(ITEM.root_info.sdb_id);
			local quantity = 0;
			if( input.required ) then
				for inv_idx=1, #d_inventory do
					local INV_ITEM = d_inventory[inv_idx];
					if( INV_ITEM.item_sdb_id == input.item_type ) then
						ITEM = INV_ITEM;
						if( not INV_ITEM.quantity and input.quantity == 1) then
							found = true;
							INPUT_ENTRY.QUANTITY_LOW = false;
							quantity = 1;
							--warn("item without quantity")
							break;
						elseif( INV_ITEM.quantity >= input.quantity ) then
							found = true;
							INPUT_ENTRY.QUANTITY_LOW = false;
							quantity = input.quantity;
							break;
						else
							INPUT_ENTRY.QUANTITY_LOW = true;
							if( INV_ITEM.quantity ) then
								quantity = INV_ITEM.quantity;
							else
								quantity = 0;
							end
						end
					end
				end
			else
				found = true;
			end
			
			INPUT_ENTRY.GROUP:Show();
			INPUT_ENTRY.ITEMTYPE = input.item_type;
			INPUT_ENTRY.UNLIMITED = input.unlimited;
			INPUT_ENTRY.INPUT_REQ = input;
			INPUT_ENTRY.OUTPUT_IDX = input.output_index;
			UpdateInputInfo( INPUT_ENTRY, ITEM, quantity )			
		end
		index = index + 1;
		INPUT_ENTRY = INPUT_ENTRIES[index];
	end
	ShowManufactureBtn();
	PreviewItem()
end

function SetRecipeOffset( offset )
	g_RecipeListOffest = math.max(0, math.min( offset, (#CFT_GLOBALS.g_recipetree_as_list - #w_RecipeWidgets) ) );
	
	if( #CFT_GLOBALS.g_recipetree_as_list - #w_RecipeWidgets <= 0 ) then
		RECIPES_SCROLL_BAR:Hide();
	else
		RECIPES_SCROLL_BAR:Show();
		RECIPES_SCROLL_BAR:SetPercent( g_RecipeListOffest/(#CFT_GLOBALS.g_recipetree_as_list - #w_RecipeWidgets) )
	end
	
	if( old_offset ~= g_RecipeListOffest ) then
		DisplayRecipes();
	end
end

function SetWorkbenchOffset( offset )
	g_WorkBenchListOffest = math.max(0, math.min( offset, (#d_workbenches - #w_WorkBenchWidgets) ) );
	
	if( #d_workbenches - #w_WorkBenchWidgets <= 0 ) then
		WORKB_SCROLL_BAR:Hide();
	else
		WORKB_SCROLL_BAR:Show();
		WORKB_SCROLL_BAR:SetPercent( g_WorkBenchListOffest/(#d_workbenches - #w_WorkBenchWidgets) )
	end
	
	if( old_offset ~= g_WorkBenchListOffest ) then
		DisplayWorkBenches();
	end
end

local updating_recipe_display = false;
local queue_display_update = false;
function DisplayRecipes()
	-- prevent calls to display recipes while updating the display
	if( updating_recipe_display ) then
		-- something change make sure to refresh when done.
		queue_display_update = true;
		return;
	end
	updating_recipe_display = true;
	if( not CFT_GLOBALS.g_recipetree_as_list or #CFT_GLOBALS.g_recipetree_as_list <= 0 )then
		for i=1, #w_RecipeWidgets do
			local RCP = w_RecipeWidgets[i];
			RCP.HIGHLIGHT:SetParam("alpha", 0 );
			RCP.NAME:SetTextColor("#FFFFFF");
			RCP.NAME:SetText("");
			RCP.GROUP:Hide();
			RCP.RECIPE = nil;
			RCP.TREE = nil;
			RCP.FOCUS:SetTag("");
		end
		updating_recipe_display = false;
		if( queue_display_update ) then
			queue_display_update = false;
			DisplayRecipes();
		end
		return;
	end

	for i=1, #w_RecipeWidgets do
		local data = CFT_GLOBALS.g_recipetree_as_list[i+g_RecipeListOffest]
		local RCP = w_RecipeWidgets[i];
		RCP.TREE = nil;
		RCP.RECIPE = nil;
		RCP.HIGHLIGHT:SetParam("alpha", 0 );
		RCP.FOCUS:SetTag("");
		
		if( data ) then
			if( data.tree ) then 
				RCP.TREE = data.tree;
				RCP.NAME:SetText( data.text );
				RCP.NAME:SetTextColor("#FFFFFF");
				RCP.GROUP:Show();
			elseif( data.recipe )then
				RCP.RECIPE = data.recipe;
				RCP.NAME:SetText( data.text );
				RCP.GROUP:Show();
				if( data.recipe == d_selected_recipe )then
					RCP.HIGHLIGHT:SetParam("alpha", 1 );
				end
				
				-- tooltip info for this entry
				RCP.FOCUS:SetTag(data.recipe.id);
				-- but, prefer a representative item id to show on tooltip
				for _,output in pairs(data.recipe.outputs) do
					if (output.item_id) then
						RCP.FOCUS:SetTag(tostring(output.item_id));
						break;
					end
				end

				if( data.refresh_can_craft )then
					data.can_craft = CFT_CanCraft(data.recipe.id, d_inventory)
					data.refresh_can_craft = false;
				end
				
				if( data.can_craft ) then
					RCP.NAME:SetTextColor("#00FF00");
				else
					RCP.NAME:SetTextColor("#FFFFFF");
				end
			end
			RCP.BORDER:SetDims("right:100%; left:"..data.offset)
		else
			RCP.HIGHLIGHT:SetParam("alpha", 0 );
			RCP.NAME:SetTextColor("#FFFFFF");
			RCP.NAME:SetText("");
			RCP.GROUP:Hide();
			RCP.RECIPE = nil;
			RCP.TREE = nil;
		end
	end
	updating_recipe_display = false;
	if( queue_display_update ) then
		queue_display_update = false;
		DisplayRecipes();
	end
end

-- INVENTORY FUNCTIONS
local g_waiting_craft_response = false;
local g_waiting_bag_response = false;
function UpdateInventory( delay )
	if( not cb_inv_update ) then
		local dur = 0.5;
		if( delay ) then
			dur = delay;
		end
		
		cb_inv_update = callback( function()
			cb_inv_update = nil;
			d_inventory = {}
			
			WebCache.Request(BAG_UPDATE);
			WebCache.Request(CRAFTING_UPDATE);
			WebCache.Request(GEAR_UPDATE);
			
			Wallet.Refresh();
			Player.RefreshInventory();
			g_waiting_craft_response = true;
			g_waiting_bag_response = true;
		end, nil, dur );
		
		if( dur <= 0.01 ) then
			cb_inv_update = nil;
		end
	end
end

function AddItemsToInventory( item_table )
	for _,item in pairs(item_table) do
		item.root_info = Game.GetRootItemInfo( item.item_sdb_id );
		item.itemInfo = Game.GetItemInfoByType( item.item_sdb_id, item.attribute_modifiers );
		if( item.root_info )then
			table.insert( d_inventory, item );
		end
		
		if( not item.quantity ) then
			item.quantity = 1;
		end

		item.available_quantity = item.quantity;
	end
end

function MarkRecipesDirty()
	for i=1, #CFT_GLOBALS.g_recipetree_as_list do
		local data = CFT_GLOBALS.g_recipetree_as_list[i];
		data.refresh_can_craft = true;
	end
end

function BagResponse( args, err)
	if( not g_waiting_bag_response ) then
		return;
	end
	if( err ) then
		-- without this we can't craft
		WebResponseFailure( err );
		return;
	end
	g_waiting_bag_response = false;
	Player.UpdateBagInventory( tostring(args) );
	
	AddItemsToInventory(args.items);
	AddItemsToInventory(args.resources);
	
	MarkRecipesDirty();
	
	DisplayRecipes();
end

function CraftInvResponse(args, err)
	if( not g_waiting_craft_response ) then
		return;
	end
	if( err ) then
		-- without this we can't craft
		WebResponseFailure( err );
		return;
	end
	g_waiting_craft_response = false;
	Player.UpdateCraftInventory( tostring(args) );
	AddItemsToInventory(args.items);
	AddItemsToInventory(args.resources);
	
	MarkRecipesDirty();
	
	DisplayRecipes();
end

function GearResponse( args, err )
	if( err ) then
		warn( tostring( err ) ) -- doesn't prevent you from crafting
		return;
	end
	d_gear_inventory = {};
	for i = 1, #args do
		local item = args[i];
		item.root_info = Game.GetRootItemInfo( item.item_sdb_id );
		item.itemInfo = Game.GetItemInfoByType( item.item_sdb_id, item.attribute_modifiers );
		table.insert( d_gear_inventory, item );
	end
end

function IsResourceTypeInInventory( id )
	local valid_itemtypes = CFT_ValidResourceTypes(id);
	for inv_idx=1, #d_inventory do
		for t=1, #valid_itemtypes do
			local ITEM = d_inventory[inv_idx];
			if( ITEM.root_info ) then
				if( ITEM.root_info.item_subtype == valid_itemtypes[t] ) then
					if( IsItemAvailable(ITEM) ) then
						return true;
					end
				end
			end
		end
	end
	
	return false;
end

-- find and remove given item from inventory
function RemoveFromInventory( ITEM )
	for i = 1, #d_inventory do
		if( d_inventory[i] == ITEM ) then
			table.remove( d_inventory, i );
			break;
		end
	end
end

-- MANUFACTURE FUNCTIONS
function ShowManufactureBtn()
	for _, INPUT in pairs(INPUT_ENTRIES) do
		if( INPUT.INPUT_REQ and not CFT_ItemHasQuantityForInput(INPUT.ITEM, INPUT.INPUT_REQ, d_num_parallel_builds) ) then
			MANUFACTURE_BTN:Hide();
			COMPONENT_TIP:Show();
			return;
		end
	end
	
	if (d_selected_recipe.blueprint_type == 6) then
		MANUFACTURE_BTN:SetTextKey("CRAFTING_REFINE", true);
	elseif (d_selected_recipe.blueprint_type == 2)then
		MANUFACTURE_BTN:SetTextKey("CRAFTING_RESEARCH", true);
	else
		MANUFACTURE_BTN:SetTextKey("CRAFTING_MANUFACTURE", true);
	end
	
	MANUFACTURE_BTN:Show();
	MANUFACTURE_BTN:Pulse( true, {tint="#008F00", freq=1.25} );
	
	COMPONENT_TIP:Hide();
end

function PreviewItem()
	for i, OP in pairs(w_OutputPreviews) do
		HideOutputPreivew(OP);
	end
	STATS:Hide();
	
	if( not d_current_recipe ) then
		error( "no recipe to preivew" )
		return;
	end
	
	local items = {}
	for c = 1, #INPUT_ENTRIES do
		local INPUT = INPUT_ENTRIES[c];
		local ITEM = INPUT.ITEM;
		if( INPUT.INPUT_REQ ) then
			if( ITEM ) then
				local item_info = {};
				item_info.item_sdb_id = ITEM.item_sdb_id;
				item_info.item_id = ITEM.item_id;
				item_info.resource_type = ITEM.resource_type;
				item_info.quantity = INPUT.QUANTITY;
				item_info.output_idx = INPUT.OUTPUT_IDX;
				items[INPUT.OUTPUT_IDX]= item_info;
			elseif( INPUT.OUTPUT_IDX ) then
				items[INPUT.OUTPUT_IDX]={output_idx = INPUT.OUTPUT_IDX, item_id=0, quantity=0, item_sdb_id=0};
			end
		end
	end
	
	table.sort(items, function(a,b)return a.output_idx < b.output_idx end)
	
		
	local args = CFT_CreateManufactureArgs(d_selected_recipe.id, d_current_recipe.inputs, items, d_num_parallel_builds, true );

	STATS_SCROLL:Reset();
	
	local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/preview";
	SendHTTPRequest(url, "POST", args, PreviewItemResponse, true );
	
	-- TODO: Add request animation
end

function PreviewItemResponse( args, err )
	if( err ) then
		-- let them know something with their preview is broken
		-- don't stop them from crafting
		warn( tostring( err ) )
		return;
	end

	if( not args.output[1] ) then
		if( #d_selected_recipe.cert_outputs > 0) then
			DisplayResearchPreview(args);
		else
			warn( "Item has no preview." );	
		end
	else
		DisplayItemPreview(args);
	end
	
	-- display build time
	if( args.build_time_secs ) then
		local total_seconds = args.build_time_secs;
		local text = ""

		local days = math.floor(total_seconds / SECONDSINDAY); -- 24hrs in seconds
		if( days >= 1 ) then 
			local lessThanADay = total_seconds % SECONDSINDAY;
			local hours = math.floor(lessThanADay / 3600);
			text = days.."D "..hours.."H "
		else
			local lessThanADay = total_seconds % SECONDSINDAY;
			local hours = math.floor(lessThanADay / 3600);
			local lessThanAHour = total_seconds % 3600;
			local minutes = math.floor(lessThanAHour / 60);
			local lessThanAMinute = total_seconds % 60;
			local seconds = math.floor(lessThanAMinute);
			
			text = hours.."H "..minutes.."M "..seconds.."S"
		end
		CRAFTING_TIME_TEXT:SetText( Component.LookupText("CRAFTING_BUILD_TIME")..text );
		CRAFTING_TIME:Show();
	else
		CRAFTING_TIME:Hide();
	end
end

function DisplayResearchPreview(args)
	HidePreviewDisplay();
	
	g_HideStats = false;
	-- handle items and components
	local attri_table = {}
	
	g_PreviewItems = {};
	g_PreviewItem = {name = d_selected_recipe.description};
	g_PreviewItem.dirty = true;
	g_PreviewItem.item_sdb_id = d_selected_recipe.id;
	g_PreviewItem.description = d_selected_recipe.description;
	
	DisplayOutputPreview();
end

function DisplayItemPreview(args)
	local output_count = #args.output;
	g_PreviewItems = {};
	g_PreviewItem = nil;
	if( output_count > 1 ) then
		-- support for multiple output display
		g_HideStats = true;
		g_PreviewItem = nil;
		
		table.sort( args.output, function (a,b) return a.item_sdb_id < b.item_sdb_id; end);
		
		local crystite = nil;
		for _, output in pairs(args.output) do
			local attri_table = {}
			if( output.attribute_modifiers )then
				for i, v in pairs( output.attribute_modifiers ) do
					table.insert(attri_table, {id=tonumber(i), value=v} );
				end
			end
		
			local preview = Game.GetPreviewItemInfo(output, attri_table);
			preview.quality = output.quality;
			preview.item_sdb_id = output.item_sdb_id;
			preview.quantity = output.quantity;
			if( output.item_sdb_id ~= 10 )then
				table.insert( g_PreviewItems, preview );
			else
				if( not crystite ) then
					crystite = preview;
				else
					crystite.quantity = crystite.quantity + preview.quantity
				end
			end
		end
		if( crystite ) then
			table.insert( g_PreviewItems, crystite );
		end
		SetOutputPreviewOffset(0)
	else
		g_HideStats = false;
		-- handle items and components
		local attri_table = {}
		if( args.output[1].attribute_modifiers )then
			for i, v in pairs( args.output[1].attribute_modifiers ) do
				table.insert(attri_table, {id=tonumber(i), value=v} );
			end
		end
		
		local preview = Game.GetPreviewItemInfo(args.output[1], attri_table);
		preview.quality = args.output[1].quality;
		preview.item_sdb_id = args.output[1].item_sdb_id;
		
		if( not preview ) then
			g_PreviewItem = nil;
			return;
		end
		local ids_mismatch = (g_PreviewItem == nil) or preview.item_sdb_id ~= g_PreviewItem.item_sdb_id;
		g_PreviewItem = preview;
		g_PreviewItem.dirty = ids_mismatch;
		g_PreviewItem.quantity = args.output[1].quantity;
	end
	DisplayOutputPreview();
end

function HideOutputPreivew(OP)
	OP.GROUP:Hide();
	OP.PLATE.SCOBJ:Hide();
	if( OP.MODEL ) then
		if( not OP.MODEL:IsValid() ) then
			OP.MODEL:Destroy();
			OP.MODEL = nil;
		else
			OP.MODEL:Hide();
		end
	end
	OP.OUTPUT = nil;
end

function HidePreviewDisplay()
	if( w_MODELS.OUTPUT ) then
		if( not w_MODELS.OUTPUT:IsValid() ) then
			w_MODELS.OUTPUT:Destroy();
			w_MODELS.OUTPUT = nil;
		else
			w_MODELS.OUTPUT:Hide();
		end
	end
	if( w_MODELS.OUTPUT_PLATE ) then
		w_MODELS.OUTPUT_PLATE:Hide();
	end
	
	for i, OP in pairs(w_OutputPreviews) do
		HideOutputPreivew(OP);
	end
	
	OUTPUT_PREVIEW:Hide();
	OUTPUT:Hide();
end

function DisplayOutputPreview()
	HidePreviewDisplay();
	
	local left_anchor = LEFT_WING:GetAnchor();
	if( #g_PreviewItems > 0 ) then		
		local count = 1;
		for i, OP in pairs(w_OutputPreviews) do
			local output = g_PreviewItems[i+g_OutputPreviewOffset];
			if( output ) then
				local item_info = Game.GetItemInfoByType(output.item_sdb_id);
				if( item_info )then			
					local TF = TextFormat.Create();
					TF:Concat( LIB_ITEMS.GetNameTextFormat(item_info, {quality = output.quality}));
					TF:ApplyTo( OP.TEXT );
					if( output.quality ) then
						OP.QUALTIY:SetText( STAT_QUALITY_TXT..": "..output.quality );
					else
						OP.QUALTIY:SetText( "" );
					end
					if( output.quantity and output.quantity > 1 ) then
						OP.QUANTITY:SetText( output.quantity.." "..Component.LookupText(CRAFTING_UNITS) );
					else
						OP.QUANTITY:SetText( "1 "..Component.LookupText(CRAFTING_UNITS) );
					end
					
					-- display output model
					if (not OP.MODEL ) then
						OP.MODEL = SinvironmentModel.Create();
						OP.MODEL:GetAnchor():SetParent(OP.ANCHOR)
					elseif( not OP.MODEL:IsValid() ) then
						OP.MODEL:Destroy();
						OP.MODEL = SinvironmentModel.Create();
						OP.MODEL:GetAnchor():SetParent(OP.ANCHOR)
					else
						OP.MODEL:Show( true );
					end
					OP.MODEL:LoadItemType(output.item_sdb_id);
					OP.MODEL:Normalize(.25);
					OP.MODEL:AutoSpin(.15);
					OP.PLATE.SCOBJ:Show();
					OP.GROUP:Show();
					OP.OUTPUT = output;
				else
					HideOutputPreivew(OP);
					warn("bad output preview data")
				end
			else
				HideOutputPreivew(OP);
			end
		end
		
		OUTPUT_PREVIEW:Show();
	elseif(g_PreviewItem)then
		local item_info = Game.GetItemInfoByType(g_PreviewItem.item_sdb_id);
		local TF = TextFormat.Create();
		TF:Concat( LIB_ITEMS.GetNameTextFormat(item_info, {quality = g_PreviewItem.quality}));
		TF:ApplyTo( OUTPUT_TEXT );

		if( g_PreviewItem.quality ) then
			OUTPUT_QUALITY:SetText( STAT_QUALITY_TXT..": "..g_PreviewItem.quality );
		else
			OUTPUT_QUALITY:SetText( "" );
		end
		if( g_PreviewItem.quantity and g_PreviewItem.quantity > 1 ) then
			OUTPUT_QUANTITY:SetText( g_PreviewItem.quantity.." units" );
		else
			OUTPUT_QUANTITY:SetText( "1 unit" );
		end
		
		if( g_PreviewItem.dirty ) then
			g_PreviewItem.dirty = false;
			local left_anchor = LEFT_WING:GetAnchor();
			if (not w_MODELS.OUTPUT or not w_MODELS.OUTPUT:IsValid()) then
				if (w_MODELS.OUTPUT) then
					w_MODELS.OUTPUT:Destroy();
				end
				w_MODELS.OUTPUT = SinvironmentModel.Create();
			end
			w_MODELS.OUTPUT:GetAnchor():SetParent(left_anchor);
			w_MODELS.OUTPUT:LoadItemType(g_PreviewItem.item_sdb_id);
			w_MODELS.OUTPUT:GetAnchor():SetParam("translation", {x=-.2, y=0, z=4.9/g_screen_ratio});
			w_MODELS.OUTPUT:GetAnchor():SetParam("scale", {x=1.5, y=1.5, z=1.5});
			w_MODELS.OUTPUT:Normalize(.45);
			w_MODELS.OUTPUT:AutoSpin(.15);
			w_MODELS.OUTPUT:Show(true);		
			w_MODELS.OUTPUT_PLATE:Show(true);
		
		end
		
		UpdateStats(g_PreviewItem);
		DisplayStats();
		COMPARE_GROUP:Show();
		DESCRIPTION:Show();
		OUTPUT:Show();
	end
	
	for _,requirement in pairs(w_RequirementIcons) do
		Component.RemoveWidget(requirement.GROUP);
	end
	w_RequirementIcons = {};
	if(g_PreviewItem and g_PreviewItem.certifications)then
		table.sort( g_PreviewItem.certifications, function(a,b) 
				a = tostring(a); b = tostring(b);
				if( (not PROGRESSION_CERT_IDS[a] and not PROGRESSION_CERT_IDS[b]) or 
					(PROGRESSION_CERT_IDS[a] and PROGRESSION_CERT_IDS[b]) ) then
					return a < b;
				else
					return not PROGRESSION_CERT_IDS[a];
				end
			end );
		
		-- display recipe cert req's
		local most_eligible = LIB_ITEMS.FindMostEligibleFrame( d_PlayerCerts, g_PreviewItem.certifications, PROGRESSION_CERT_IDS )
		for _,cert_id in pairs(g_PreviewItem.certifications) do
			local certInfo = Game.GetCertificationInfo(cert_id);
			local REQ = { GROUP=Component.CreateWidget( [[<WebImage name="WebIcon" dimensions="width:48; height:48" style="fixed-bounds:true; eatsmice:false">
																<FocusBox dimensions="dock:fill">
																	<Events>
																		<OnMouseEnter bind="OnRequirementEnter"/>
																		<OnMouseLeave bind="HideTooltip"/>
																	</Events>
																</FocusBox>
															</WebImage>
														]]
						,REQUIREMENT_LIST) };
			REQ.GROUP:SetUrl( INGAME_HOST.."/assets/constraints/"..certInfo.web_icon..".png" )
			REQ.DESC = Component.LookupText("REQUIRES_CERT", certInfo.name);
			table.insert( w_RequirementIcons, REQ );
			REQ.GROUP:SetTag(#w_RequirementIcons);
			if( not most_eligible.has_cert[tostring(cert_id)] ) then
				REQ.REQ_MET = false;
				Component.CreateWidget( [[<StillArt dimensions="right:100%; bottom:100%; width:10; height:14" style="texture:DialogSymbolsv2; region:icon_locked; tint:FF0000"/>]],REQ.GROUP );
			else
				REQ.REQ_MET = true;
			end
		end
		REQUIREMENT_LIST:SetDims("width:"..(48*#g_PreviewItem.certifications));
	end
end

function OnRequirementEnter( args )
	local widget = args.widget:GetParent();
	local REQ = w_RequirementIcons[tonumber(widget:GetTag())];
	if( REQ.REQ_MET ) then
		ShowTooltip(REQ.DESC);
	else
		ShowTooltip(REQ.DESC, {frame_color="#FF0000"});
	end
end

function ManufactureResponse( args, err )
	if( err ) then
		-- something bad happened, the player will need to re-enter their last manufacture request
		WebResponseFailure( err, Component.LookupText("CRAFTING_BUILD_ERR"), function() 	MANUFACTURE_BTN:Show(); COMPONENT_TIP:Hide(); end );
		return;
	end
	
	-- update local inventory
	for c = 1, #INPUT_ENTRIES do
		local INPUT_REQ = INPUT_ENTRIES[c].INPUT_REQ;
		if( INPUT_REQ ) then
			local ITEM = INPUT_ENTRIES[c].ITEM
			if( ITEM ) then
				if( INPUT_REQ.unlimited or not ITEM.quantity ) then
					RemoveFromInventory( ITEM );
				else
					ITEM.quantity = ITEM.quantity - INPUT_REQ.quantity * d_num_parallel_builds;
					if( ITEM.quantity <= 0 ) then
						RemoveFromInventory( ITEM )
					end
				end
			end
		end
	end
	
	if( d_selected_recipe.blueprint_type == 2 ) then
		d_selected_recipe.unavailable = true;
		GenerateRecipeList();
	end
	
	SelectRecipe( nil );
	DisplayRecipes();
	
	UpdateWorkbench();
	UpdateInventory(0.5);
end

function IncrementParallelBuildCount( value )
	UpdateParallelBuildCount( d_num_parallel_builds + value );
end

function UpdateParallelBuildCount( value )
	local max_builds = 1;
	if( d_current_recipe ) then
		max_builds = d_current_recipe.max_parallel;
	end
	value = math.min(value, max_builds);
	value = math.max(value, 1);
	
	NUM_PARALLEL_TXT:SetText( value );
	NUM_PARALLEL_SLIDER:SetPercent( value/max_builds );
	if( d_selected_recipe and value ~= d_num_parallel_builds ) then	
		d_num_parallel_builds = value;
		for _,INPUT in pairs(INPUT_ENTRIES) do
			if( INPUT.INPUT_REQ ) then
				local quantity = d_num_parallel_builds * INPUT.INPUT_REQ.quantity;
				local available = 0;
				if( INPUT.ITEM and INPUT.ITEM.available_quantity ) then
					available = INPUT.ITEM.available_quantity + INPUT.QUANTITY;
				end
				
				if( available > quantity ) then
					UpdateInputInfo(INPUT, INPUT.ITEM, quantity);
				else
					UpdateInputInfo(INPUT, INPUT.ITEM, available);
				end
			end
		end
		PreviewItem();
		ShowManufactureBtn();
	end
end

-- INPUT FUNCTIONS
function DisplayInputsMenu( )
	if( not g_SelectedInput ) then
		return;
	end
	
	local material_type = g_SelectedInput.MATERIALTYPE;
	local item_type = g_SelectedInput.ITEMTYPE;
	local name = "";
	if( material_type~= 0 ) then
		name = CFT_GLOBALS.d_resource_types[tostring(material_type)].name;
	else
		if( g_SelectedInput.ITEM )then
			name = g_SelectedInput.ITEM.root_info.name;
		end
	end
	if(#name < 1)then
		warn("Missing name for input.")
	end
	INPUT_MENU_TITLE:SetText( Component.LookupText("CRAFTING_INPUT_TITLE", name));
	
	local INPUT = g_SelectedInput;
	if(INPUT.ITEM) then
		local TF = TextFormat.Create();
		TF:Concat( LIB_ITEMS.GetNameTextFormat(INPUT.ITEM.itemInfo, {quality = INPUT.ITEM.quality}));
		TF:ApplyTo(INPUT_MENU_SELECTED_ITEM);
	else
		TextFormat.Clear(INPUT_MENU_SELECTED_ITEM);
		INPUT_MENU_SELECTED_ITEM:SetTextKey("CRAFTING_NOTHING");
		INPUT_MENU_SELECTED_ITEM:SetTextColor("#FFFFFF")
	end
	for i = 1, #w_InputMenuWidgets do
		local ENTRY = d_InputMenuItems[i+g_InputMenuOffset]
		local WIDGET = w_InputMenuWidgets[i];
		if( ENTRY ) then
			if( ENTRY.create ) then
				TextFormat.Clear(WIDGET.NAME);
				WIDGET.NAME:SetTextKey("CRAFTING_CREATE_COMP")
				WIDGET.NAME:SetTextColor("#FFFF6F")
				WIDGET.STAT:SetText("");
				WIDGET.QUANTITY:SetText("");
			elseif(ENTRY.empty)then
				TextFormat.Clear(WIDGET.NAME);
				WIDGET.NAME:SetTextKey("CRAFTING_EMPTY_COMP")
				WIDGET.NAME:SetTextColor("#FFFF6F")
				WIDGET.STAT:SetText("");
				WIDGET.QUANTITY:SetText("");
			else
				local ITEM = ENTRY.item
				local text = "";
				local stat_name = "";
				local stat_value = ITEM.quality;
							
				if( INPUT.INPUT_REQ.resource_type > 0 ) then
					stat_name = "stat"..INPUT.INPUT_REQ.resource_type;
					stat_value = ITEM[stat_name];
				end
				local quantity = ITEM.available_quantity;
				if( INPUT.ITEM and ITEM == INPUT.ITEM ) then
					quantity = quantity + INPUT.QUANTITY
				end
				
				WIDGET.QUANTITY_BG:SetParam("tint", "#3f3f3f" );			
				if( INPUT.INPUT_REQ.quantity ) then
					if( INPUT.INPUT_REQ.quantity > 1 ) then
						if( not ITEM.quantity or INPUT.INPUT_REQ.quantity > quantity ) then
							WIDGET.QUANTITY_BG:SetParam("tint", "#6F0000" );
						end
					end
				end

				local TF = TextFormat.Create();
				TF:Concat( LIB_ITEMS.GetNameTextFormat(ITEM.itemInfo, {quality = ITEM.quality}));
				TF:ApplyTo(WIDGET.NAME);
				WIDGET.NAME:SetDims("top:0"); -- fix for resources not displaying the quality correctly
				
				if( stat_value )then
					WIDGET.STAT:SetText(""..stat_value);
				else
					WIDGET.STAT:SetText("0");
				end
				
				WIDGET.QUANTITY:SetText(quantity);
			end
			WIDGET.GROUP:Show();
		else
			WIDGET.GROUP:Hide();
		end
	end
	
	if(g_SelectedInput.INPUT_REQ.unlimited and g_SelectedInput.MATERIALTYPE ~= 0) then
		INPUT_MENU_SELECTED_ITEM:SetDims( "bottom:100%-4; left:4; height:24; right:40%" )
		INPUT_MENU_SELECTED_ITEM_BG:SetDims( "bottom:100%-4; left:4; height:24; right:40%" )
		INPUT_MENU_QUANTITY:Show();
		INPUT_MENU_MAX_QUANTITY:Show();
		INPUT_MENU_QUANTITY_BG:Show();
		if( INPUT.ITEM ) then
			d_SelectedInputItem = INPUT.ITEM;
			INPUT_MENU_QUANTITY:SetText( tostring(INPUT.QUANTITY) );
			if( INPUT.ITEM.quantity ) then
				INPUT_MENU_MAX_QUANTITY:SetText("/"..INPUT.ITEM.available_quantity+INPUT.QUANTITY);
			else
				INPUT_MENU_MAX_QUANTITY:SetText("/0");
			end
		else
			INPUT_MENU_QUANTITY:SetText( 0 );
			INPUT_MENU_MAX_QUANTITY:SetText("/0");
		end
	else
		INPUT_MENU_QUANTITY:Hide();
		INPUT_MENU_MAX_QUANTITY:Hide();
		INPUT_MENU_QUANTITY_BG:Hide();
		INPUT_MENU_SELECTED_ITEM:SetDims( "bottom:100%-4; left:4; height:24; right:75%" )
		INPUT_MENU_SELECTED_ITEM_BG:SetDims( "bottom:100%-4; left:4; height:24; right:75%" )
	end
end

function SetInputMenuOffset( offset )
	g_InputMenuOffset = math.max(0, math.min( offset, (#d_InputMenuItems - #w_InputMenuWidgets) ) );
	
	if( (#d_InputMenuItems - #w_InputMenuWidgets) <= 0 ) then
		INPUT_MENU_SCROLL_BAR:Hide();
	else
		INPUT_MENU_SCROLL_BAR:Show();
		INPUT_MENU_SCROLL_BAR:SetPercent( g_InputMenuOffset/(#d_InputMenuItems - #w_InputMenuWidgets) )
	end
	
	if( old_offset ~= g_InputMenuOffset ) then
		DisplayInputsMenu()
	end
end

-- WORKBENCH FUNCTIONS
function SendWorkbenchUpdateRequest()
	local url = API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches";
	SendHTTPRequest(url, "GET", nil, WorkbenchResponse);
end

function UpdateWorkbench(delay)
	if( cb_wb_update ) then
		cancel_callback( cb_wb_update );
		cb_wb_update = nil;
	end
	
	SendWorkbenchUpdateRequest();
	
	Wallet.Refresh();
end

function DelayedWorkbenchUpdate(delay)
	if( not cb_wb_update ) then
		local dur = 0.1;
		if( delay ) then
			dur = delay;
		end
		
		cb_wb_update = callback( function()
				cb_wb_update = nil;
				SendWorkbenchUpdateRequest();
			end, nil, dur );
		
		if( dur <= 0.01 ) then
			cb_wb_update = nil;
		end
		
		Wallet.Refresh();
	else
		warn("Attempting to Update Workbench with pending call.")
	end
end

function WorkbenchResponse(args, err)
	if( err ) then
		-- can't craft without workbenches
		if( g_wb_update_attempts <= 5 ) then
			DelayedWorkbenchUpdate( g_wb_update_attempts * g_wb_update_attempts * 5);
			g_wb_update_attempts = g_wb_update_attempts + 1;
			warn("Workbench Update Failed: retry "..g_wb_update_attempts)
		else
			error("Too many failed responses trying to update workbenches.")
		end
		WebResponseFailure( err );
		return;
	end
	
	g_wb_update_attempts = 0;
	d_time_since_workbench_update = System.GetClientTime();
	
	local inc_workbenches = args;
	local num_wb_display = #d_workbenches;
	
	-- find and unlock VIP workbenches
	for id,bench in pairs(inc_workbenches) do
		if( bench.unlock_cost and bench.unlock_cost.type == "unlocked")then
			if(not g_purchasing_workbenches[id] or System.GetElapsedTime(g_purchasing_workbenches[id]) > 30) then
				last_workbench_id = id;
				OnWBPurchase_Accept(id);
				g_purchasing_workbenches[id] = System.GetClientTime();				
			end
		elseif( g_purchasing_workbenches[id] )then
			g_purchasing_workbenches[id] = nil; -- the last work bench has been purchased
		end
	end
	
	-- update or remove workbenches
	local ids_to_remove = {}
	for id,bench in pairs(d_workbenches) do
		if( not inc_workbenches[bench.id])then
			table.insert(ids_to_remove, 1, id);
		else
			bench.data = inc_workbenches[bench.id]; -- update the data for this bench
			inc_workbenches[bench.id] = nil;			
		end
	end
	for id,value in pairs(ids_to_remove) do
		table.remove(d_workbenches, value);
	end
	
	-- any benches remaining are either purchase-able or need to added to displayable
	d_wb_purchasable = {};
	for id, bench in pairs(inc_workbenches) do
		if( bench.unlock_cost ) then
			if( bench.unlock_cost.type ~= "unlocked" )then
				table.insert( d_wb_purchasable, {id = id, data = bench} );
			end
		else
			local vip = ((id == "5") or (id == "6")); -- VIP benches will always be "5" or "6"
			table.insert( d_workbenches, {id = id, data = bench, vip=vip} );
		end
	end
	
	-- VIP slots should appear at the end of the workbench
	function SortWorkbenches(a, b)
		if( (a.vip ~= b.vip) ) then
			return b.vip;
		end
		return tonumber(a.id) < tonumber(b.id)
	end
	table.sort(d_workbenches, SortWorkbenches)
	UpdateWorkbenchData();
	
	if( g_manufacture_post_wb_update )then
		g_manufacture_post_wb_update = false;
		if( d_current_recipe and g_unlock_req_via_manu ) then
			g_unlock_req_via_manu = false;
			OnManufactureRequest();
			return;
		end
	end
	
	DisplayWorkBenches();

	PURCHASE_WORKBENCHES_BTN:Enable(#d_wb_purchasable > 0);
	
	if( num_wb_display  ~= #d_workbenches ) then
		WORKB_SCROLL_BAR:SetScrollSteps(#d_workbenches);
		WORKB_SCROLL_BAR:SetJumpSteps(1);
		if(#d_workbenches > 0 ) then
			WORKB_SCROLL_BAR:SetParam("thumbsize", math.max(.1, #w_WorkBenchWidgets/ #d_workbenches));
		else
			WORKB_SCROLL_BAR:SetParam("thumbsize", 1);
		end
	end
end

function UpdateInputInfo( INPUT, ITEM, NEW_QUANTITY )
	if( INPUT.ITEM ) then
		if( INPUT.ITEM ~= ITEM and INPUT.ITEM.available_quantity) then
			INPUT.ITEM.available_quantity = INPUT.ITEM.available_quantity + INPUT.QUANTITY;
			-- check that we go over the item quanitity
			if( INPUT.ITEM.available_quantity > INPUT.ITEM.quantity ) then
				warn("Adding back more than available!")
				INPUT.ITEM.available_quantity = INPUT.ITEM.quantity;
			end
			INPUT.QUANTITY = 0;
		end
	end
	
	if( not INPUT.INPUT_REQ )then
		INPUT.ITEM = nil;
		INPUT.NAME:SetText("");
		INPUT.COUNT:SetText("");
		INPUT.MATERIALTYPE = 0;
		INPUT.ITEMTYPE = 0
		INPUT.QUANTITY = 0;
		INPUT.UNLIMITED = false;
		INPUT.INPUT_REQ = nil;
		INPUT.QUANTITY_LOW = false;
		
		if( INPUT.PLATE ) then
			Component.RemoveSceneObject(INPUT.PLATE.SCOBJ);
			INPUT.PLATE = nil;
		end
		
		local SINMODEL = w_MODELS.SUBCOMPONENTS[INPUT];
		if (SINMODEL and SINMODEL:IsValid()) then
			SINMODEL:Unload();
		end
		
		return;
	end
	local OLD_QUANTITY = INPUT.QUANTITY;
	if( NEW_QUANTITY ) then
		INPUT.QUANTITY = NEW_QUANTITY;
	else
		INPUT.QUANTITY = 0;
	end
	
	local quantity = 0;
	if( INPUT.INPUT_REQ.quantity and INPUT.INPUT_REQ.quantity > 0 )then
		quantity = INPUT.INPUT_REQ.quantity;
	else
		quantity = 1;
	end
	quantity = quantity * d_num_parallel_builds;
	
	if( not INPUT.INPUT_REQ.unlimited and ITEM) then
		if( not ITEM.quantity)then
			INPUT.QUANTITY = 0;
		elseif(ITEM.available_quantity and ITEM.available_quantity < quantity) then
			INPUT.QUANTITY =  ITEM.quantity;
		else
			INPUT.QUANTITY = quantity;
		end
	end
	
	local OLD_ITEM = INPUT.ITEM;
	INPUT.ITEM = ITEM;
	
	-- JSU
	if (INPUT.INPUT_REQ) then
		local SINMODEL = w_MODELS.SUBCOMPONENTS[INPUT];
		if (not SINMODEL or not SINMODEL:IsValid()) then
			-- make a new one
			SINMODEL = SinvironmentModel.Create();
			w_MODELS.SUBCOMPONENTS[INPUT] = SINMODEL;
			SINMODEL:GetAnchor():SetParent(INPUT.ANCHOR);
		end
		if( not INPUT.PLATE ) then
			INPUT.PLATE = {SCOBJ=Component.CreateSceneObject("GUI_Icon_Plate_001")};
			INPUT.PLATE.ANCHOR = INPUT.PLATE.SCOBJ:GetAnchor();
			INPUT.PLATE.ANCHOR:SetParent(INPUT.ANCHOR);
			INPUT.PLATE.ANCHOR:SetParam("translation", {x=0,y=0,z=-.05} );
			INPUT.PLATE.ANCHOR:SetParam("scale", {x=0.5,y=0.5,z=0.5});
			INPUT.PLATE.ANCHOR:SetParam("rotation", {axis={x=1,y=0,z=0}, angle=80} );
			INPUT.PLATE.SCOBJ:SetParam("tint", "6f0000");
		end
		INPUT.ANCHOR:ParamTo("translation", INPUT.ANCHOR:GetParam("translation"), 1);	-- force update
		
		local itemTypeId = (ITEM or {}).sdb_id;
		if (not itemTypeId or itemTypeId == 0) then
			itemTypeId = INPUT.INPUT_REQ.item_type;
			if (not itemTypeId or itemTypeId == 0) then
				itemTypeId = CFT_FindMeAnItem(INPUT.INPUT_REQ.material_type);
			end
		end
		if (itemTypeId) then
			SINMODEL:LoadItemType(itemTypeId);
		else
			-- load placeholder for material

			warn("no item type for "..tostring(INPUT.INPUT_REQ));

			SINMODEL:LoadItemType('10');
		end
		SINMODEL:Normalize(.15);
		SINMODEL:AutoSpin(.1);
	else
		if( SINMODEL ) then
			SINMODEL:Unload();
		end
		if( INPUT.PLATE.SCOBJ ) then
			Component.RemoveSceneObject(INPUT.PLATE.SCOBJ);
			INPUT.PLATE = nil;
		end
	end
	-- /JSU
	
	local material_type = INPUT.MATERIALTYPE;
	local name = "";
	local stat_value = 0
	local quality_value = 0
	local resource_type = INPUT.INPUT_REQ.resource_type;
	local prefered_stat = "";
	
	local INPUT_REQ = INPUT.INPUT_REQ;
	if( ITEM and ITEM["stat"..INPUT_REQ.resource_type] ) then
		stat_value = ITEM["stat"..INPUT_REQ.resource_type];
	end
	
	if( material_type~= 0 ) then
		name = CFT_GLOBALS.d_resource_types[tostring(material_type)].name;
		if( ITEM )then
			if( ITEM.quality ) then
				quality_value = ITEM.quality;
			else
				stat_value = 0;
			end
			name = ITEM.root_info.name;
			
			if( CFT_ItemHasQuantityForInput( ITEM, INPUT_REQ, d_num_parallel_builds ) )then
				INPUT.PLATE.SCOBJ:SetParam("tint", "006f00");
			else
				INPUT.PLATE.SCOBJ:SetParam("tint", "6f0000");
			end
		elseif( not INPUT_REQ.required ) then
			INPUT.PLATE.SCOBJ:SetParam("tint", "00006f");
		else
			INPUT.PLATE.SCOBJ:SetParam("tint", "6f0000");
		end
	else
		if( ITEM )then
			name = ITEM.root_info.name;
		end
		
		if( ITEM and ITEM.quality ) then
			quality_value = ITEM.quality;
		else
			stat_value = 0;
		end
		
		if( INPUT.INPUT_REQ.required ) then
			INPUT.PLATE.SCOBJ:SetParam("tint", "6f0000");
		else
			INPUT.PLATE.SCOBJ:SetParam("tint", "00006f");
		end
		for item_idx=1, #d_inventory do
			local ITEM = d_inventory[item_idx];
			if( ITEM.item_sdb_id == INPUT_REQ.item_type ) then
				if( CFT_ItemHasQuantityForInput( ITEM, INPUT_REQ, d_num_parallel_builds ) )then
					INPUT.PLATE.SCOBJ:SetParam("tint", "006f00");
				else
					INPUT.PLATE.SCOBJ:SetParam("tint", "6f0000");
				end
				break;
			end
		end
	end	

	if( ITEM and ITEM.available_quantity ) then
		if(OLD_ITEM ~= INPUT.ITEM) then
			ITEM.available_quantity = math.max( 0, ITEM.available_quantity - INPUT.QUANTITY);
		elseif(NEW_QUANTITY ~= OLD_QUANTITY)then
			if( not NEW_QUANTITY ) then
				NEW_QUANTITY = 0;
			end
			ITEM.available_quantity = math.max( 0, ITEM.available_quantity - (NEW_QUANTITY - OLD_QUANTITY));
		end
	end
	OLD_QUANTITY = 0;
	if(INPUT_REQ.stat_name)then
		prefered_stat = INPUT_REQ.stat_name;

		if( stat_value > 0  ) then
			prefered_stat = prefered_stat..": "..stat_value;
		end
	end

	local TF = TextFormat.Create();
	local rarity_color = "#FFFFFF";
	if( ITEM ) then
		TF:Concat( LIB_ITEMS.GetNameTextFormat(ITEM.root_info, {quality = ITEM.quality}));
	else
		TF:AppendText(name);
		if( quality_value > 0 ) then
			TF:AppendText(" "..quality_value);
		end
	end
	
	if( #prefered_stat > 0 ) then
		TF:AppendText("\n"..prefered_stat);
	end
	
	if( INPUT.INPUT_REQ.attribute_name ) then
		TF:AppendText("\n"..INPUT.INPUT_REQ.attribute_name);
	end
	TF:ApplyTo( INPUT.NAME );
	
	INPUT.NAME:SetDims( "top:8; height:"..INPUT.NAME:GetTextDims().height);
	INPUT.NAME_BG:SetDims( "top:8; height:"..INPUT.NAME:GetTextDims().height+8);
	
	INPUT.COUNT:SetTextColor( "#FFFFFF" );
	if( INPUT.ITEM ) then
		if( INPUT.MATERIAL_TYPE and INPUT_REQ.unlimited ) then
			INPUT.COUNT:SetText( "x "..INPUT.QUANTITY );
		elseif( INPUT.QUANTITY and INPUT.QUANTITY > 0 or INPUT.QUANTITY_LOW ) then
			local text = "x "..INPUT.QUANTITY.."/"..quantity;
			if( INPUT.QUANTITY < INPUT_REQ.quantity )then
				text = CRAFTING_LOW_QUANTITY.."\n"..text;
			end
			INPUT.COUNT:SetText( text );
			if( INPUT.QUANTITY < INPUT_REQ.quantity )then
				INPUT.COUNT:SetTextColor( "#FF0000", "#000000", 1, #CRAFTING_LOW_QUANTITY );
			end
		else
			INPUT.COUNT:SetText( "x 0".."/"..quantity );
		end
	elseif(material_type~= 0)then
		INPUT.COUNT:SetText(SELECT_ITEM_TXT.."\nx0/"..quantity );
		INPUT.COUNT:SetTextColor( "#FFFF00", "#000000", 1, #SELECT_ITEM_TXT );
	end
	INPUT.COUNT:SetDims( "height:"..INPUT.COUNT:GetTextDims().height);
	INPUT.COUNT_BG:SetDims( "height:"..INPUT.COUNT:GetTextDims().height+4);	
end

function UpdateWorkbenchData()
	local min_time = -1;
	local play_complete_sound = false;
	for id, bench in pairs(d_workbenches) do
		if( bench )then
			if( bench.data.unlock_cost ) then
				error("displayable workbench for purchase: "..id)
			elseif( not bench.data.blueprint_id )then
				-- no workbench loaded nothing to do
			else
				local time_left = bench.data.seconds_remaining;
				local total_time = bench.data.ready_at - bench.data.started_at;				
				if( time_left <= 0 )then
					-- check if we've played a complete message
					if(not bench.build_complete)then
						bench.build_complete = true;
						play_complete_sound = true;
						
						local item = Game.GetRootItemInfo(bench.data.blueprint_id)
						Component.GenerateEvent("MY_NOTIFY", {text=Component.LookupText("CRAFTING_COMPLETE", item.name)});
					end
				else
					bench.build_complete = false;
					if( time_left > 3600 * 24 ) then
					else
						if( min_time > 0 ) then
							min_time = math.min( min_time, time_left );
						else
							min_time = time_left;
						end
					end
				end
			end
		end		
	end

	if( play_complete_sound ) then
		PlayDialog( { "Play_ManufacturingEnded_01", "Play_ManufacturingEnded_02", "Play_ManufacturingEnded_03" } )
	end
	if( min_time > 0 and min_time < 3600 )then
		DelayedWorkbenchUpdate(min_time);
	end	
end

function DisplayWorkBenches()
	if( RIGHT_WING:IsVisible())then
		local time_elasped = System.GetElapsedTime(d_time_since_workbench_update );
		for i=1, #w_WorkBenchWidgets do
			local bench = d_workbenches[i+g_WorkBenchListOffest];
			
			local WB = w_WorkBenchWidgets[i];
			WB.TIMER:StopTimer();
			WB.TIMER:Hide();
			WB.TIME_TEXT:Hide();
			WB.BUTTON:Hide();
			WB.RB_BUTTON:Hide();
			WB.CANCEL:Show();
			WB.BUTTON:TintPlate("#6f6f6f");
			WB.BUTTON:Pulse(false);
			
			-- display output model		
			if( bench and bench.data )then
				local data = bench.data;
				WB.GROUP:Show();
				WB.PROGRESS_BG:SetParam("tint", "6f6f6f")
				WB.PROGRESS_MASK:SetParam("tint", "8f8f8f")
				WB.PROGRESS_MASK:SetMaskDims("left:0; width:0%");
				WB.PLATE.SCOBJ:Show();
			
				WB.VIP:Hide();
				-- display VIP icon for VIP workbenches
				if( bench.vip)then
					WB.VIP:Show();
				end
			
				if( data.unlock_cost ) then
					if( data.unlock_cost.type == "unlocked" )then
						WB.BENCH = bench;
						WB.NAME:SetText("");
						WB.BUILD_COMPLETE = false;
						WB.CANCEL:Hide();
						
						if( WB.MODEL ) then
							if( not WB.MODEL:IsValid() ) then
								WB.MODEL:Destroy();
								WB.MODEL = nil;
							else
								WB.MODEL:Hide();
							end
						end
						
						WB.BUTTON:SetTextKey("CRAFTING_WB_PURCHASE");
						WB.BUTTON:Show();
					end
				elseif( not data.blueprint_id )then
					WB.BENCH = bench;
					WB.NAME:SetTextKey("CRAFTING_WB_EMPTY");
					WB.BUILD_COMPLETE = false;
					
					if( WB.MODEL ) then
						if( not WB.MODEL:IsValid() ) then
							WB.MODEL:Destroy();
							WB.MODEL = nil;
						else
							WB.MODEL:Hide();
						end
					end
					WB.CANCEL:Hide();
				else
					local item = Game.GetRootItemInfo(data.blueprint_id)
					WB.BENCH = bench;
					WB.NAME:SetText(item.name)
					local time_left = data.seconds_remaining - time_elasped;
					local total_time = data.ready_at - data.started_at;				
					if( time_left <= 0 )then
						WB.NAME:SetText( item.name)
						WB.PROGRESS_BG:SetParam("tint", "#006F00")
						WB.PROGRESS_MASK:SetParam("tint", "#006F00")
						
						for i = 1, 300 do
							WB.PROGRESS_BG:QueueParam("tint", "#00CF00", 0.4, 0, "ease-in" )
							WB.PROGRESS_BG:QueueParam("tint", "#006F00", 0.4, 0, "ease-out" )
						end
						WB.BUTTON:TintPlate("#006F00")
						WB.BUTTON:Pulse(true, {tint="#00CF00", freq=1.25});
						
						local recipe = CFT_FindRecipe(data.blueprint_id);
						if( #recipe.cert_outputs > 0 ) then
							WB.BUTTON:SetTextKey("CRAFTING_RESEARCH_REQUEST");
						else
							WB.BUTTON:SetTextKey("CRAFTING_UNLOAD_REQUEST");
						end
						WB.BUTTON:Show();

						WB.CANCEL:Hide();

					else
						WB.PROGRESS_MASK:SetMaskDims("left:0; width:"..( (1-time_left/total_time)*100.0).."%");
						WB.PROGRESS_MASK:MaskMoveTo( "left:0; width:100%", time_left, 0, "linear" );
						WB.BUILD_COMPLETE = false;
						WB.BUILD_COMPLETE_SND  = false;
						WB.PROGRESS_BG:SetParam("tint", "00006f")
						WB.PROGRESS_MASK:SetParam("tint", "0000ff")
						if( time_left > 3600 * 24 ) then
							local days_left = math.floor(time_left/(SECONDSINDAY));
							local lessThanADay = time_left % SECONDSINDAY;
							local hours_left = math.floor(lessThanADay / 3600);
							if( days_left > 1 )then
								WB.TIME_TEXT:SetText( Component.LookupText("TIME_REMAINING")..days_left.." "..Component.LookupText("DAYS_REMAINING").." "..hours_left.."H");
							else
								WB.TIME_TEXT:SetText( Component.LookupText("TIME_REMAINING")..days_left.." "..Component.LookupText("DAY_REMAINING").." "..hours_left.."H");
							end
							WB.TIME_TEXT:Show();
						else
							if( time_left > 3600 ) then
								WB.TIMER:SetFormat( "Time Remaining: %.0HH %.0MM" )
							else
								WB.TIMER:SetFormat( "Time Remaining: %.0MM %.0SS" )
							end
							WB.TIMER:Show();
							WB.TIMER:StartTimer(time_left, true);
						end
						if( data.rb_complete_cost ) then
							WB.RB_TEXT:SetText(tostring(data.rb_complete_cost));
							WB.BUTTON:Show();
							WB.BUTTON:TintPlate("ffff00");
						end
						WB.CANCEL:Show();
						WB.BUTTON:SetTextKey("CRAFTING_WB_FINALIZE_BTN");
						WB.BUTTON:Show();
						WB.RB_BUTTON:Show();
					end
					
					if (not WB.MODEL ) then
						WB.MODEL = SinvironmentModel.Create();
						WB.MODEL:GetAnchor():SetParent(WB.ANCHOR:GetAnchor())
					elseif( not WB.MODEL:IsValid() ) then
						WB.MODEL:Destroy();
						WB.MODEL = nil;

						WB.MODEL = SinvironmentModel.Create();
						WB.MODEL:GetAnchor():SetParent(WB.ANCHOR:GetAnchor());
					end
					WB.MODEL:LoadItemType(data.blueprint_id);
					WB.MODEL:GetAnchor():SetParam("translation", {x=0, y=-0.05, z=0});
					WB.MODEL:Normalize(1);
					WB.MODEL:AutoSpin(.15);
					WB.MODEL:Show(true);
				end
			else
				WB.PLATE.SCOBJ:Hide();
				if( WB.MODEL ) then
					if( not WB.MODEL:IsValid() ) then
						WB.MODEL:Destroy();
						WB.MODEL = nil;
					else
						WB.MODEL:Hide();
					end
				end
				WB.GROUP:Hide();
				WB.VIP:Hide();
				WB.BENCH = nil;
			end
		end	
		
		g_WorkBenchListOffest = math.max(0, math.min( g_WorkBenchListOffest, (#d_workbenches - #w_WorkBenchWidgets) ) );
	
		if( #d_workbenches - #w_WorkBenchWidgets <= 0 ) then
			WORKB_SCROLL_BAR:Hide();
		else
			WORKB_SCROLL_BAR:Show();
			WORKB_SCROLL_BAR:SetPercent( g_WorkBenchListOffest/(#d_workbenches - #w_WorkBenchWidgets) )
		end
	end
end

function FindEmptyWorkbench()
	-- todo be able to search multiple workbenches

	for id, bench in pairs(d_workbenches) do
		if( not bench.data.blueprint_id and not bench.data.unlock_cost )then
			return bench;
		end
	end
	
	if( OpenWorkbenchPurchaseScreen() ) then
		return "purchase";
	end
	
	return nil;
end

function OpenWorkbenchPurchaseScreen()
	local found = false;
	local workbench_costs = {}
	for _, bench in pairs(d_wb_purchasable) do
		if(bench.data.unlock_cost and not bench.purchased)then
			local unlock_type = bench.data.unlock_cost.type;
			if(unlock_type~="unlocked")then
				local amount = bench.data.unlock_cost.amount;
				if( not workbench_costs[unlock_type] ) then
					workbench_costs[unlock_type] = {amount = amount};
					workbench_costs[unlock_type].bench = bench;
					found = true;
				elseif(workbench_costs[unlock_type].amount > amount)then
					workbench_costs[unlock_type].amount = amount;
					workbench_costs[unlock_type].bench = bench;
				end
			end
		end
	end
	
	if( not found ) then
		return false;
	end
	local count = 1;
	-- purchase buttons
	if(workbench_costs["crystite"])then
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("text"):SetText("x"..workbench_costs["crystite"].amount);
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus"):BindEvent("OnMouseDown",
			function()
				WB_PURCHASEPROMPT:Close();
				local text = Component.LookupText("CRAFTING_WB_PURCHASE", workbench_costs["crystite"].amount, Component.LookupText("CRYSTITE") );
				Wallet.PromptTypeSpend( "crystite", workbench_costs["crystite"].amount, text, 
					function( spend )
						if spend then
							OnWBPurchase_Accept( workbench_costs["crystite"].bench.id);
							workbench_costs["crystite"].bench.purchased = true;
						end
					end
				)
			end
			);
			
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus"):BindEvent("OnMouseEnter",
		function()
			WB_PURCHASEPROMPT_CRYSTITE:ParamTo("exposure", 1, 0.1)
			ShowTooltip(Component.LookupText("CRAFTING_WB_PURCHASE_TT", workbench_costs["crystite"].amount,  Component.LookupText("CRYSTITE")) );
		end
		);
		
		count = count + 1;
	else
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("text"):SetText("");
		WB_PURCHASEPROMPT_CRYSTITE:SetParam("tint", "#6f6f6f");
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus"):BindEvent("OnMouseDown", function()end );
		WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus"):BindEvent("OnMouseEnter",
			function()
				ShowTooltip( Component.LookupText("CRAFTING_NO_WB_PURCHASE") );
				WB_PURCHASEPROMPT_CRYSTITE:ParamTo("exposure", 1, 0.1)
			end
			);
	end
	WB_PURCHASEPROMPT_CRYSTITE:GetChild("focus"):BindEvent("OnMouseLeave",
		function()
			WB_PURCHASEPROMPT_CRYSTITE:ParamTo("exposure", 0, 0.1);
			HideTooltip();
		end
		);
	
	if( workbench_costs["redbean"] and workbench_costs["redbean"].amount > 0 )then
		WB_PURCHASEPROMPT_REDBEAN:GetChild("text"):SetText( "x"..workbench_costs["redbean"].amount);
		WB_PURCHASEPROMPT_REDBEAN:GetChild("focus"):BindEvent("OnMouseDown",
			function()
				WB_PURCHASEPROMPT:Close();
				local text = Component.LookupText("CRAFTING_WB_PURCHASE", workbench_costs["redbean"].amount, Component.LookupText("REDBEANS") );
				Wallet.PromptRedBeanSpend( workbench_costs["redbean"].amount, text, 
					function(spend)
						if spend then
							OnWBPurchase_Accept( workbench_costs["redbean"].bench.id );
							workbench_costs["redbean"].bench.purchased = true;
						end
					end
				)
			end
			);
		WB_PURCHASEPROMPT_REDBEAN:GetChild("focus"):BindEvent("OnMouseEnter",
			function()
				WB_PURCHASEPROMPT_REDBEAN:ParamTo("exposure", 1, 0.1)
				ShowTooltip(Component.LookupText("CRAFTING_WB_PURCHASE_TT", workbench_costs["redbean"].amount,  Component.LookupText("REDBEANS")) );
			end
			);
		
		count = count + 1;
	else
		WB_PURCHASEPROMPT_REDBEAN:Hide();
		WB_PURCHASEPROMPT_REDBEAN:GetChild("text"):SetText("");
		WB_PURCHASEPROMPT_REDBEAN:SetParam("tint", "#6f6f6f");
		WB_PURCHASEPROMPT_REDBEAN:GetChild("focus"):BindEvent("OnMouseDown", function()end );
		WB_PURCHASEPROMPT_REDBEAN:GetChild("focus"):BindEvent("OnMouseEnter",
			function()
				WB_PURCHASEPROMPT_CRYSTITE:ParamTo("exposure", 1, 0.1)
				ShowTooltip( Component.LookupText("CRAFTING_NO_WB_PURCHASE") );
			end);
	end
	WB_PURCHASEPROMPT_REDBEAN:GetChild("focus"):BindEvent("OnMouseLeave",
		function()
			WB_PURCHASEPROMPT_REDBEAN:ParamTo("exposure", 0, 0.1);
			HideTooltip();
		end
		);
		
	if( Player.GetVIPTime() ~= nil ) then
		WB_PURCHASEPROMPT_VIP:GetChild("focus"):BindEvent("OnMouseEnter",
			function()
				WB_PURCHASEPROMPT_VIP:ParamTo("exposure", 1, 0.1)
				ShowTooltip( Component.LookupText("CRAFTING_VIP_TT") );
			end
		);
	else
		WB_PURCHASEPROMPT_VIP:GetChild("focus"):BindEvent("OnMouseEnter",
			function()
				WB_PURCHASEPROMPT_VIP:ParamTo("exposure", 1, 0.1)
				ShowTooltip( Component.LookupText("CRAFTING_NO_VIP_TT") );
			end
		);
	end
	WB_PURCHASEPROMPT_VIP:GetChild("focus"):BindEvent("OnMouseLeave",
		function()
			WB_PURCHASEPROMPT_VIP:ParamTo("exposure", 0, 0.1);
			HideTooltip();
		end
		);
	
	WB_PURCHASEPROMPT_LAYOUT:SetDims( "width:"..(count*72+(count-1)*48) );

	WB_PURCHASEPROMPT:Open();
	current_menu = WB_PURCHASEPROMPT;
	return true;
end

function OnShowVIPProgram()
	Component.GenerateEvent("MY_WEBUI_TOGGLE",{panel="vip"}); -- open VIP screen
	WB_PURCHASEPROMPT:Close();

	-- close so the next time the printer is openned we refresh the workbenches and have the VIP benches
	if( FRAME:IsVisible() )then
		OnClose();
	end
end

function CloseWorkbenchPurchaseScreen()
	WB_PURCHASEPROMPT:Close();
end

function OnVIPUpdate()
	DelayedWorkbenchUpdate(0.5);
	callback(UpdateWorkbench, 0, 15);
	callback(UpdateWorkbench, 0, 30);
end

-- STATS FUNCTIONS
function UpdateStats( preview )
	d_Stats = {};
	local stats = preview.stats;
	if( stats ) then
		for id, value in pairs(stats) do
			if( not c_IgnoreStats[id] ) then
				table.insert( d_Stats, {id=id, value=value, format="%0.2f"} );
			end
		end
	end
	if( preview.attributes )then
		local attributes = preview.attributes;
		for i = 1, #attributes do
			local att = attributes[i];
			table.insert( d_Stats, {id=att.stat_id, value=att.value, name=att.display_name, format=att.format, inverse=att.inverse} );
		end
	end
	
	if( preview.durability and preview.durability.pool > 0 )then
		table.insert( d_Stats, {id="Durability", value=preview.durability.pool, name= Component.LookupText("DURABILITY"), ["format"]="%d", inverse=false} );
	end
end

function DisplayStats()
	STATS_SCROLL:Reset();
	STATS_SCROLL:UpdateSize();
	if( not d_selected_recipe or g_HideStats) then	
		if( g_HideStats ) then
			warn("Attempting to show stats, when hidden")
		end
		return;
	end
	
	local IsContrained = false;
	if( g_PreviewItem and g_PreviewItem.constraints ) then
		for name,data in pairs(CONSTRAINTS_TABLE) do
			local value = g_PreviewItem.constraints[name];
			if( value ~= 0 ) then
				IsContrained = true;
				break;
			end
		end
	end
	
	if( #d_Stats <= 0 and not IsContrained )then
		return;
	end
	
	STATS:Show();
		
	local compare_item_data = nil;
	if( d_compare_item_info ) then
		local item = d_compare_item_info;
		local item_id = {item_sdb_id=item.item_sdb_id};
		local attributes = {}; 
		
		if( item.attribute_modifiers )then
			for i, v in pairs( item.attribute_modifiers ) do
				table.insert(attributes, {id=tonumber(i), value=v} );
			end
		end
		compare_item_data = Game.GetPreviewItemInfo(item_id, attributes);
	end
	local count = 1;
	
	function AddStatRow( text )
		local row = STATS_SCROLL:AddRow(count);
		local w_widget = Component.CreateWidget("stat_slot", row.GROUP);
		row:SetWidget(w_widget);
		
		local w_text = w_widget:GetChild("text")
		w_text:SetText(text);
		
		row:UpdateSize({height=24});
		count = count + 1;
		return w_widget;
	end
	
	function FindCompareStat( stat )
		if( not compare_item_data ) then return nil; end
		
		if( stat.id == "Durability" ) then
			return  {value = compare_item_data.durability.pool, format="%d" };
		end
		
		if( compare_item_data.stats[stat.id] ) then
			return {value = compare_item_data.stats[stat.id], format="%0.2f" };
		end
		
		for _,att in pairs(compare_item_data.attributes) do
			if( att.stat_id == stat.id ) then
				return att;
			end
		end
		return nil;			
	end
	
	function AddConstraintCompareText( w_text, d_text, format, value, cmp_value )
		local text_start = #d_text + 1;
		d_text = d_text..unicode.format(" "..format, cmp_value );
		w_text:SetText(d_text);
		local greater_than_color = "#00FF00";
		local less_than_color = "#FF0000";
		if( value > cmp_value) then
			w_text:SetTextColor(greater_than_color, "000000", 1);
			w_text:SetTextColor(less_than_color, "000000", text_start);
		elseif( value == cmp_value) then
			-- equal to no need to color code
		else
			w_text:SetTextColor(less_than_color, "000000", 1);
			w_text:SetTextColor(greater_than_color, "000000", text_start);
		end
	end
	
	local w_widget = AddStatRow( Component.LookupText("CRAFTING_CONSTRAINTS") );
	local w_text = w_widget:GetChild("text")
	w_text:SetFont("Bold_11")
	
	local item_constr = g_PreviewItem.constraints;
	local cmp_item_constr = compare_item_data and compare_item_data.constraints;
	
	if( g_PreviewItem.constraints ) then
		for name,data in pairs(CONSTRAINTS_TABLE) do
			local value = item_constr[name];
			if( value and value ~= 0 ) then
				local d_text = data.name;
				d_text = d_text..unicode.format(": "..data.format, value );
				local w_widget = AddStatRow(d_text);
				if( cmp_item_constr ) then
					AddConstraintCompareText( w_widget:GetChild("text"), d_text, data.format, value, cmp_item_constr.mass );
				end
			end
		end
	end
	
	if( #d_Stats > 0 ) then
		local w_widget = AddStatRow( Component.LookupText("STATS") );
		local w_text = w_widget:GetChild("text")
		w_text:SetFont("Bold_11")
		for _, stat in pairs(d_Stats) do			
			local d_text = "";
			local text_format = "%s: %0.2f"
			if( stat.format and #stat.format > 0 ) then
				text_format = "%s: "..stat.format;
			end
			if( stat.name )then
				d_text = unicode.format(text_format, stat.name, stat.value );
			else
				local name = Component.LookupText( "STAT_"..stat.id )
				d_text = unicode.format(text_format, name, stat.value);
			end
			local w_widget = AddStatRow(d_text);
			
			local cmp_stat = FindCompareStat( stat );
			if( cmp_stat ) then
				local text_start = #d_text + 1;
				if( cmp_stat.format and #cmp_stat.format > 0 )then
					d_text = d_text..unicode.format(" "..stat.format, cmp_stat.value );
				else
					d_text = d_text..unicode.format(" %0.2f", cmp_stat.value );
				end
				
				local greater_than_color = "#00FF00";
				local less_than_color = "#FF0000";
				if( cmp_stat.inverse )then
					greater_than_color = "#FF0000";
					less_than_color = "#00FF00";
				end
				
				local w_text = w_widget:GetChild("text")
				w_text:SetText(d_text);
				if( stat.value > cmp_stat.value) then
					w_text:SetTextColor(greater_than_color, "000000", 1);
					w_text:SetTextColor(less_than_color, "000000", text_start);
				elseif( stat.value == cmp_stat.value) then
					-- equal to no need to color code
				else
					w_text:SetTextColor(less_than_color, "000000", 1);
					w_text:SetTextColor(greater_than_color, "000000", text_start);
				end
			end
		end
	end
	STATS_SCROLL:UpdateSize();
end

function IsItemAvailable( item )
	local found = false;
	for i = 1, #INPUT_ENTRIES do
		if( INPUT_ENTRIES[i].ITEM == item and item.available_quantity <=0 )then
			return false;
		end
	end
	return true;
end

function SetScrollText( text, w_TEXT, w_SCROLLER, w_ROW )
	-- workaround to make sure we can scroll to all text
	w_SCROLLER:ScrollToPercent(0);
	if( #text > 0 ) then
		w_TEXT:SetText( text );
	end
	local bounds = w_TEXT:GetTextDims();
	w_TEXT:SetDims( "left:0;width:100%-5;height:"..bounds.height+w_TEXT:GetParam("padding")*2 );
	w_ROW:UpdateSize();
end

-- COMPARE FUNCTIONS
function DisplayCompare()
	local found = false;
	local count = 0;
	
	local item_ids = {};
	
	for i,v in pairs(d_selected_recipe.outputs) do
		local item_info = Game.GetRootItemInfo(v.item_id);	
		item_ids[item_info.crafting_type_id] = true;
	end
	
	for i=1, #w_CompareWidgets do
		local WIDGET = w_CompareWidgets[i];
		WIDGET.TEXT:SetText("");
		TextFormat.Clear(WIDGET.TEXT);
	end
	
	for i=1, #d_gear_inventory do
		local ITEM = d_gear_inventory[i];
		if( ITEM and  ITEM.root_info and item_ids[ITEM.root_info.crafting_type_id]) then
			count = count + 1;
			if( count < #w_CompareWidgets ) then
				local WIDGET = w_CompareWidgets[count];
				WIDGET.GROUP:Show();
				local TF = TextFormat.Create();
				TF:Concat( LIB_ITEMS.GetNameTextFormat(ITEM.root_info, { quality = ITEM.quality }));
				TF:ApplyTo( WIDGET.TEXT );
				WIDGET.ITEM = ITEM;
				found = true;
			end
		end
	end
	
	for i=1, #d_inventory do
		local ITEM = d_inventory[i];
		if( ITEM and  ITEM.root_info and item_ids[ITEM.root_info.crafting_type_id]) then
			count = count + 1;
			if( count < #w_CompareWidgets ) then
				local WIDGET = w_CompareWidgets[count];
				WIDGET.GROUP:Show();
				local TF = TextFormat.Create();
				TF:Concat( LIB_ITEMS.GetNameTextFormat(ITEM.root_info, { quality = ITEM.quality }));
				TF:ApplyTo( WIDGET.TEXT );
				WIDGET.ITEM = ITEM;
				found = true;
			end
		end
	end
	
	return count;
end

-- WEB FUNCTIONS
function SendHTTPRequest( url, cmd, args, response_func, queue )
	if( g_keep_closed ) then
		return;
	end
	
	if( HTTP.IsRequestPending(url) and queue)then
		-- remove similar pending calls
		for i=1, #g_request_queue do
			if( g_request_queue[i].url == url )then
				table.remove(g_request_queue,i);
			end
		end
		-- insert new call
		local request = { url=url, cmd=cmd, args=args, response_func=response_func }
		table.insert(g_request_queue,request);
		
		if( not cb_request ) then
			ProcessRequestQueue();
		end
	else
		HTTP.IssueRequest(url, cmd, args, response_func);
	end
end

function ProcessRequestQueue()
	cb_request = nil;
	local request_queue = g_request_queue;
	g_request_queue = {};
	-- attempt to send pending webquests
	for i = 1, #request_queue do
		local request = request_queue[i];
		if( not HTTP.IsRequestPending(request.url) )then
			HTTP.IssueRequest(request.url, request.cmd, request.args, request.response_func );
		else
			table.insert(g_request_queue,request);
		end
	end
	
	if( #g_request_queue > 0 ) then
		cb_request = callback(ProcessRequestQueue, nil, 0.05);
	end
end


function ShowMouseBlock()
	VisualSlotter.Activate(true);
	VisualSlotter.PleaseWait(Component.LookupText("SYNCING_WITH_SIN"));
	MOUSE_BLOCK:ParamTo("alpha", 0.5, 0.25);
	MOUSE_BLOCK:Show(true);
	UpdatePleaseWait();
end

function HideMouseBlock()
	VisualSlotter.Activate(false);
	VisualSlotter.PleaseWait(false);
	MOUSE_BLOCK:QueueParam("alpha", 0, 0.1);
	MOUSE_BLOCK:Show(false, 0.1 );
end

function UpdatePleaseWait()
	if( not cb_please_wait ) then
		cb_please_wait = callback( PleaseWaitCallback, nil, 0.1 );
	end
end

function PleaseWaitCallback()
	cb_please_wait = nil;
	
	if( g_waiting_for_mark_complete ) then
		ShowMouseBlock();
		return;
	end
	
	-- ignore if only waiting for the item preview response 
	local urls_to_wait = { API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches" }					
	for _,bench in pairs(d_workbenches) do
		local GUID = bench.data.workbench_guid;
		table.insert( urls_to_wait,
			API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..GUID.."/mark_complete"
		 );
		 
		 table.insert( urls_to_wait,
			API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..GUID.."/cancel"
		 );

		 table.insert( urls_to_wait,
			API_HOST.."/api/v3/characters/"..CFT_GLOBALS.g_charId.."/manufacturing/workbenches/"..GUID.."/load"
		 );
	end
	
	for _,url in pairs(urls_to_wait) do
		if( HTTP.IsRequestPending(url) )then
			ShowMouseBlock();
			return;
		end
	end
	
	HideMouseBlock();
end

local cb_keep_closed = nil;
function WebResponseFailure( err, ui_message, response_func )
	if( FRAME:IsVisible() )then
		g_waiting_for_mark_complete = false;
		HideMouseBlock();
		if( --[[err.status == 500 or]] err.data.code == "ERR_UNKNOWN" 
			or err.status == 403 and err.data.code == "ERR_NOT_ONLINE") then
			OnClose();
			Component.GenerateEvent("MY_NOTIFY",{text = "S.I.N Connection Failure", dur = 3});
			
			if( cb_request ) then
				cancel_callback( cb_request );
			end
			
			g_request_queue = {};
			
			if( not g_keep_closed ) then
				g_keep_closed = true;
				callback( function() g_keep_closed=false end, nil, CRAFTING_UI_LOCK_DURATION )
			end
			error( tostring( err ) );			
		else
			warn(tostring(err));
			local err_text = err.status.."\n\n";
			if(err.data.message)then
				err_text = err_text..err.data.message;
			end
			if( ui_message ) then
				err_text = err_text.."\n"..ui_message;
			end
			
			function close()
				if( response_func ) then
					response_func();
				end
				ErrorDialog.Hide()
			end
			
			ErrorDialog.Display( err_text, close );
			ErrorDialog.AddOption( {label=Component.LookupText("Close"), OnPress=close} );
			g_request_queue = {};
			
			-- something went wrong. fix it
			UpdateInventory(0.5);
			if( g_wb_update_attempts == 0 ) then
				if( cb_request ) then
					cancel_callback( cb_request );
				end				
				g_request_queue = {};
				
				UpdateWorkbench();
			end
		end
	end
	UpdatePleaseWait();
end

-- SOUND FUNCTION
-- plays a random dialog from a list of sounds
function PlayDialog( sound_table )
	if( not g_playing_sound ) then
		System.PlaySound( sound_table[math.random(1,#sound_table)] );
		g_playing_sound = true;
		
		callback( function() g_playing_sound=false; end, nil, 10 );
	end
end

function FinalizeWidgets( widget_table )
	for _,WIDGET in pairs(widget_table)do
		Component.RemoveWidget(WIDGET.GROUP);
		if( WIDGET.MODEL ) then
			WIDGET.MODEL:Destroy();
			WIDGET.MODEL = nil;
		end
		if( WIDGET.OUTPUT_PLATE ) then
			Component.RemoveSceneObject(WIDGET.PLATE.SCOBJ);
		end
		if( WIDGET.ANCHOR ) then
			--Component.RemoveAnchor(WIDGET.ANCHOR);
		end
	end
end

function ShowItemTooltip(itemInfo, compare)
	if( not w_ItemToolTip ) then
		return;
	end
	
	w_ItemToolTip:DisplayInfo(itemInfo);
	if compare then
		w_ItemToolTip:CompareAgainst(compare);
	end
	ShowTooltip(w_ItemToolTip.GROUP, w_ItemToolTip:GetBounds());
end

function ShowTooltip(tip, args)
	args = args or {}
	args.delay = TOOLTIP_DELAY
	ToolTip.Show(tip, args)
end

function HideTooltip()
	ToolTip.Show(nil);
end

