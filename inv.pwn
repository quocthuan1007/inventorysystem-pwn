const
	INV_MAX_ITEM_PER_PAGE = 15;

enum E_INV
{
	InvShow,
	InvCurPage,
	InvMaxPage,

	InvClickAble,
	List:InvItems,
}

enum E_INV_ITEM_DATA
{
	e_inv_item_id,
	e_inv_item_use,
	e_inv_item_name[64],
	// for PC
	// for Mobile
	e_inv_item_model,
	Float:e_inv_item_RotX,
	Float:e_inv_item_RotY,
	Float:e_inv_item_RotZ,
	Float:e_inv_item_Zoom,
	e_modelid,
}

static const InvArray[][E_INV_ITEM_DATA] =
{
	{pCash, 0, "Tien mat", 1550, 0.0, 0.0, 0.0, 0.0},        // C?c ti?n (Money Stack)
	{pPot, 1, "Pot", 1575, 0.0, 0.0, 0.0, 0.0},              // Cái bình (Pot)
	{pPhoneBook, 0, "Danh Ba", 2886, 0.0, 0.0, 0.0, 0.0},    // Cu?n s? (Phone Book)
	{pDice, 0, "Xuc Xac", 19896, 0.0, 0.0, 0.0, 0.0},        // Xúc x?c (Dice)
	{pCigar, 0, "Thuoc La", 19873, 0.0, 0.0, 0.0, 0.0},      // Ði?u thu?c (Cigar)
	{pMats, 0, "Vat Lieu", 2358, 0.0, 0.0, 0.0, 0.0},        // Thùng v?t li?u (Materials Box)
	{pRadio, 0, "Radio", 2103, 0.0, 0.0, 0.0, 0.0},          // Cái radio (Radio)
	{pPnumber, 0, "Dien Thoai", 18867, 0.0, 0.0, 0.0, 0.0}   // Ði?n tho?i (Mobile Phone)
};


static
	Player[MAX_PLAYERS][E_INV],
	Text:TDEditor_TD[4],
	PlayerText:PTD_Item[MAX_PLAYERS][INV_MAX_ITEM_PER_PAGE][2], // [0 = Item, 1 = Amount]
	Float:inv_pos@[INV_MAX_ITEM_PER_PAGE][2]; // [0 TextDraw, 1 Player TextDraw]

stock Inventory_Show(playerid)
{
	if(Player[playerid][InvShow])
		return Inventory_Hide(playerid);

	new List: lst = Player[playerid][InvItems];
	if(list_valid(lst) && list_clear(lst))
	{
		new item_count;
		for(new item, i = 0; i < sizeof(InvArray); i ++) ///ai zo vps vay
		{
			item = InvArray[i][e_inv_item_id];
			if(PlayerInfo[playerid][item])
			{
				printf("%d, %d, %d", item, pCash, PlayerInfo[playerid][item]);
				list_add(lst, i);
			}

		}
		for(new i = 0; i < sizeof(TDEditor_TD); i ++)
		{
			TextDrawShowForPlayer(playerid, TDEditor_TD[i]);
		}
		item_count = list_size(lst);
		SelectTextDraw(playerid, -1);
		Inventory_ShowPage(playerid, 0);
		Player[playerid][InvShow] = 1;
		Player[playerid][InvMaxPage] = floatround
		(
			item_count % INV_MAX_ITEM_PER_PAGE == 0?
			item_count / INV_MAX_ITEM_PER_PAGE:
			item_count / INV_MAX_ITEM_PER_PAGE + 1
		);
		return 1;
	}
	return 0;
}

stock Inventory_Hide(playerid)
{
	Player[playerid][InvShow] = 0;
	for(new i = 0; i < INV_MAX_ITEM_PER_PAGE; i ++)
	{
		Inventory_HideIndex(playerid, i);
	}
	for(new i = 0; i < sizeof(TDEditor_TD); i ++)
	{
		TextDrawHideForPlayer(playerid, TDEditor_TD[i]);
	}
	CancelSelectTextDraw(playerid);
	Inventory_ActionDestroy(playerid);
	PlayerPlaySound(playerid, 1136, 0.0, 0.0, 0.0);
	return 1;
}

static Inventory_GetXY(index, &Float:x, &Float:y)
{
	x = inv_pos@[index][0];
	y = inv_pos@[index][1];
}

static Inventory_SetSelectAble(playerid, select)
{
	for(new j = 0; j < INV_MAX_ITEM_PER_PAGE; j ++)
	{
		if(PTD_Item[playerid][j][0])
		{
			PlayerTextDrawSetSelectable(playerid, PTD_Item[playerid][j][0], select);
			PlayerTextDrawShow(playerid, PTD_Item[playerid][j][0]);
		}
	}
	Player[playerid][InvClickAble] = select;
}

static Inventory_ShowPage(playerid, page = 0)
{
	new
		List:lst = Player[playerid][InvItems];

	Player[playerid][InvClickAble] = 1;
	Player[playerid][InvCurPage] = page;
	PlayerPlaySound(playerid, 17803, 0.0, 0.0, 0.0);
	for(new str[33], item, result, v = 0, i = 0; i < INV_MAX_ITEM_PER_PAGE; i ++)
	{
		v = i + page * INV_MAX_ITEM_PER_PAGE;
		result = (list_valid(lst) && v < list_size(lst));

		if(result)
		{
			item = list_get(lst, v);
			Inventory_ShowIndex(playerid, i, InvArray[item][e_inv_item_model], PlayerInfo[playerid][InvArray[item][e_inv_item_id]], InvArray[item][e_inv_item_id]);
		}
		else Inventory_HideIndex(playerid, i);
	}
	return 1;
}

stock Inventory_ShowIndex(playerid, index, item, amount, type)
{
	new
		Float:x, Float:y, str[16];

	Inventory_GetXY(index, x, y);
	Inventory_HideIndex(playerid, index);

	PTD_Item[playerid][index][0] = CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont(playerid, PTD_Item[playerid][index][0], 5);
	PlayerTextDrawTextSize(playerid, PTD_Item[playerid][index][0], 47.000000, 56.000000);
	PlayerTextDrawSetPreviewModel(playerid, PTD_Item[playerid][index][0], item);
	PlayerTextDrawSetPreviewRot(playerid, PTD_Item[playerid][index][0], 0.0, 0.0, -45.0, 1.0);
	PlayerTextDrawSetSelectable(playerid, PTD_Item[playerid][index][0], true);
	PlayerTextDrawColor(playerid, PTD_Item[playerid][index][0], 0x999999CC);
	PlayerTextDrawSetShadow(playerid, PTD_Item[playerid][index][0], 0);
	PlayerTextDrawAlignment(playerid, PTD_Item[playerid][index][0], 1);
	PlayerTextDrawShow(playerid, PTD_Item[playerid][index][0]);


	format(str, sizeof(str), "%s%s", type == pCash ? "$" : "", number_format(amount));
	PTD_Item[playerid][index][1] = CreatePlayerTextDraw(playerid, x + 43.399902, y + 1.144447, str);
	PlayerTextDrawLetterSize(playerid, PTD_Item[playerid][index][1], 0.122666, 0.849183);
	PlayerTextDrawSetProportional(playerid, PTD_Item[playerid][index][1], 1);
	PlayerTextDrawAlignment(playerid, PTD_Item[playerid][index][1], 3);
	PlayerTextDrawSetShadow(playerid, PTD_Item[playerid][index][1], 0);
	PlayerTextDrawFont(playerid, PTD_Item[playerid][index][1], 2);

	PlayerTextDrawShow(playerid, PTD_Item[playerid][index][1]);
	PlayerTextDrawShow(playerid, PTD_Item[playerid][index][0]);

	printf("%s, %s, %f, %f", str, item, x, y);
}

stock Inventory_HideIndex(playerid, index)
{
	for(new i = 0; i < 2; i ++)
	{
		if(PTD_Item[playerid][index][i] != PlayerText:0)
		{
			PlayerTextDrawDestroy(playerid, PTD_Item[playerid][index][i]);
			PTD_Item[playerid][index][i] = PlayerText:0;
		}
	}
}

#include <YSI\y_hooks>
hook OnPlayerConnect(playerid)
{
	new
		i[E_INV];

	Player[playerid] = i;
	Player[playerid][InvItems] = list_new();
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(list_valid(Player[playerid][InvItems]))
	{
		list_delete(Player[playerid][InvItems]);
	}

	for(new i = 0; i < INV_MAX_ITEM_PER_PAGE; i ++)
	{
		Inventory_HideIndex(playerid, i);
	}
	return 1;
}

hook OnGameModeInit()
{
	TDEditor_TD[0] = TextDrawCreate(166.666687, 105.222221, "ld_dual:white");
	TextDrawFont(TDEditor_TD[0], 4);
	TextDrawLetterSize(TDEditor_TD[0], 0.600000, 2.000000);
	TextDrawTextSize(TDEditor_TD[0],	304.000000, 225.000000);
	TextDrawSetOutline(TDEditor_TD[0], 1);
	TextDrawSetShadow(TDEditor_TD[0], 0);
	TextDrawAlignment(TDEditor_TD[0], 1);
	TextDrawColor(TDEditor_TD[0], 0x171717FF);
	TextDrawBackgroundColor(TDEditor_TD[0], 0x171717FF);
	TextDrawBoxColor(TDEditor_TD[0], 50);
	TextDrawUseBox(TDEditor_TD[0], 1);
	TextDrawSetProportional(TDEditor_TD[0], 1);
	TextDrawSetSelectable(TDEditor_TD[0], 0);

	// Tiêu d?
	TDEditor_TD[3] = TextDrawCreate(166.666687, 95.222221, "INVENTORY");
 	TextDrawLetterSize(TDEditor_TD[3], 0.35, 1.5);
	TextDrawColor(TDEditor_TD[3], 0xFFFFFFFF);
	TextDrawSetOutline(TDEditor_TD[3], 0);
	TextDrawFont(TDEditor_TD[3], 2);

	// Nút dóng
	TDEditor_TD[1] = TextDrawCreate(422.333435, 87.800018, "Close");
	TextDrawFont(TDEditor_TD[1], 1);
	TextDrawLetterSize(TDEditor_TD[1], 0.362500, 1.650000);
	TextDrawTextSize(TDEditor_TD[1], 25.000000, 65.500000);
	TextDrawSetOutline(TDEditor_TD[1], 0);
	TextDrawSetShadow(TDEditor_TD[1], 0);
	TextDrawAlignment(TDEditor_TD[1], 2);
	TextDrawColor(TDEditor_TD[1], -1);
	TextDrawBackgroundColor(TDEditor_TD[1], 255);
	TextDrawBoxColor(TDEditor_TD[1], 0x7872FEFF);
	TextDrawUseBox(TDEditor_TD[1], 1);

	TextDrawSetProportional(TDEditor_TD[1], 1);
	TextDrawSetSelectable(TDEditor_TD[1], 1);

	// Nút trang ti?p theo
	TDEditor_TD[2] = TextDrawCreate(417.000091, 308.866760, "Trang >>");
	TextDrawFont(TDEditor_TD[2], 1);
	TextDrawLetterSize(TDEditor_TD[2], 0.362500, 1.650000);
	TextDrawTextSize(TDEditor_TD[2], 25.000000, 65.500000);
	TextDrawSetOutline(TDEditor_TD[2], 0);
	TextDrawSetShadow(TDEditor_TD[2], 0);
	TextDrawAlignment(TDEditor_TD[2], 2);
	TextDrawColor(TDEditor_TD[2], -1);
	TextDrawBackgroundColor(TDEditor_TD[2], 255);
	TextDrawBoxColor(TDEditor_TD[2], 0x7872FEFF);
	TextDrawUseBox(TDEditor_TD[2], 1);

	TextDrawSetProportional(TDEditor_TD[2], 1);
	TextDrawSetSelectable(TDEditor_TD[2], 1);


    new
        Float:X = 177.933456,
        Float:Y = 116.422241;

    for(new i = 0; i < INV_MAX_ITEM_PER_PAGE; i ++)
    {
		if(i && (i % 5 == 0))
		{
			X = 177.933456;
			Y += 5.0 + 58.0;
		}
        inv_pos@[i][0] = X;
		inv_pos@[i][1] = Y;

        X += 58.5;
    }
}

CMD:tuidocuatoi(playerid,params[])
{
	Inventory_Show(playerid);
	return 1;
}

forward Inv_OnResponse(playerid, Text:clickedid);
public Inv_OnResponse(playerid, Text:clickedid)
{
	if(Player[playerid][InvShow])
	{
		if(clickedid == Text:INVALID_TEXT_DRAW || clickedid == TDEditor_TD[1] /* Button Click */)
		{
			return Inventory_Hide(playerid);
		}
		else if(clickedid == TDEditor_TD[2] && Player[playerid][InvClickAble])
		{
			new
				page = Player[playerid][InvCurPage],
				maxPage = Player[playerid][InvMaxPage];

			if(++page >= maxPage)
			{
				page = 0;
			}
			// printf("> %d, %d", page, maxPage);
			Inventory_ShowPage(playerid, page);
		}
	}
	return 1;
}

forward Inv_OnClick(playerid, PlayerText:playertext);
public Inv_OnClick(playerid, PlayerText:playertext)
{
	if(Player[playerid][InvShow])
	{
		new page = Player[playerid][InvCurPage];
		for(new item, i = 0, clicked = page * INV_MAX_ITEM_PER_PAGE; clicked < (page + 1) * INV_MAX_ITEM_PER_PAGE; i ++, clicked ++)
		{
			if(0 <= i < INV_MAX_ITEM_PER_PAGE)
			{
				if(playertext == PTD_Item[playerid][i][0])
				{
					new
						await_result, Float:x, Float:y, List:list = Player[playerid][InvItems];

					if(0 <= clicked < list_size(list))
					{
						Inventory_GetXY(i, x, y);
						item = list_get(list, clicked);
						Inventory_SetSelectAble(playerid, 0);
						PlayerPlaySound(playerid, 6801, 0.0, 0.0, 0.0);
						await_result = await Inventory_ActionShow(playerid, x, y, InvArray[item][e_inv_item_use]);
						//
						PlayerPlaySound(playerid, 17803, 0.0, 0.0, 0.0);
						Inventory_SetSelectAble(playerid, 1);
						switch(await_result)
						{
							case INV_BTN_USE:
							{
								CallLocalFunction("Inv_OnClickUse", "dd", playerid, InvArray[item][e_inv_item_id]);
							}
							case INV_BTN_INFO:
							{
								CallLocalFunction("Inv_OnClickInfo", "dd", playerid, InvArray[item][e_inv_item_id]);
							}
						}
					}
					return 1;
				}
			}
		}
		InvAction_OnClick(playerid, playertext);
	}
	return 1;
}

forward Inv_OnClickUse(playerid, itemid);
public Inv_OnClickUse(playerid, itemid)
{
	switch(itemid)
	{
		case pPot:
		{
			return cmd_usepot(playerid, "");
		}
	}
	return 1;
}

forward Inv_OnClickInfo(playerid, itemid);
public Inv_OnClickInfo(playerid, itemid)
{
	switch(itemid)
	{
	    case pDice:
	    {
	        return SendClientMessageEx(playerid,-1,"/dice de do xuc sac");
		}
		case pPnumber:
		{
		    return SendClientMessageEx(playerid,-1,"/call de goi dien thoai");
		}
		case pPhoneBook:
		{
		    return SendClientMessageEx(playerid,-1,"Danh ba dung de tim kiem so dien thoai /number de tim");
		}
		case pCash:
		{
			return SendClientMessageEx(playerid, -1, "Vat pham dung de choi gai.");
		}
		case pPot:
		{
			return SendClientMessageEx(playerid, -1, "Can sa, dung vao de hoi mau.");
		}
	}
	return 1;
}

