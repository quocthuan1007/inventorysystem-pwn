static arr_action[][32] =
{
	"button_use", 		//	INV_BTN_USE
	"button_info", 		//	INV_BTN_INFO
	"button_cancel"  	//	INV_BTN_CANCEL
};

enum
{
	INV_BTN_USE,
	INV_BTN_INFO,
	INV_BTN_CANCEL,
}

static
	var[MAX_PLAYERS],
	Task:task_Action[MAX_PLAYERS],
	PlayerText:Action[MAX_PLAYERS][sizeof(arr_action)];

Task:Inventory_ActionShow(playerid, Float:X, Float:Y, btn_use = 1)
{
    var[playerid] = 1;

    if (task_Action[playerid] == Task:0)
    {
        task_Action[playerid] = task_new();
    }

    task_detach();
    task_yield(task_Action[playerid]);

    X += 40.0;
    Y += 30.0;

    new str[32];
    for (new i = 0; i < sizeof(arr_action); i++)
    {
        // N?u không cho dùng nút "SUDUNG" (index 0), thì b? qua
        if (btn_use == 0 && i == 0)
            continue;

        // H?y TextDraw cu n?u có
        if (Action[playerid][i] != PlayerText:0)
        {
            PlayerTextDrawDestroy(playerid, Action[playerid][i]);
            Action[playerid][i] = PlayerText:0;
        }

        // T?o TextDraw d?ng zin
        format(str, sizeof(str), "[ %s ]", arr_action[i]);

        Action[playerid][i] = CreatePlayerTextDraw(playerid, X, Y, str);
        PlayerTextDrawLetterSize(playerid, Action[playerid][i], 0.35, 1.3);
        PlayerTextDrawFont(playerid, Action[playerid][i], 1);
        PlayerTextDrawColor(playerid, Action[playerid][i], 0xFFFFFFFF);
        PlayerTextDrawSetOutline(playerid, Action[playerid][i], 1);
        PlayerTextDrawSetSelectable(playerid, Action[playerid][i], true);
        PlayerTextDrawBackgroundColor(playerid, Action[playerid][i], 255);
        PlayerTextDrawSetShadow(playerid, Action[playerid][i], 0);
        PlayerTextDrawShow(playerid, Action[playerid][i]);

        Y += 25.0; // Tang spacing cho d? b?m trên mobile
    }

    var[playerid] = 0;
    return task_Action[playerid];
}


Inventory_ActionDestroy(playerid)
{
	for(new i = 0; i < sizeof(arr_action); i ++)
	{
		if(Action[playerid][i] != PlayerText:0)
		{
			PlayerTextDrawDestroy(playerid, Action[playerid][i]);
			Action[playerid][i] = PlayerText:0;
		}
	}

	new
		const Task:tsk = task_Action[playerid];

	task_Action[playerid] = Task: 0;
	if(task_valid(tsk)) task_delete(tsk);
}

#include <YSI\y_hooks>
hook OnPlayerConnect(playerid)
{
	for(new i = 0; i < sizeof(arr_action); i ++)
	{
		Action[playerid][i] = PlayerText:0;
	}
	task_Action[playerid] = Task: 0;
}

hook OnPlayerDisconnect(playerid, reason)
{
	Inventory_ActionDestroy(playerid);
}

forward InvAction_OnClick(playerid, PlayerText:playertext);
public InvAction_OnClick(playerid, PlayerText:playertext)
{
	if(task_Action[playerid] != Task:0 && var[playerid] == 0)
	{
		for(new i = 0; i < sizeof(arr_action); i ++)
		{
			if(playertext == Action[playerid][i])
			{
				if(task_valid(task_Action[playerid]))
				{
					task_set_result(task_Action[playerid], i);
				}
				else
				{
					Inventory_Hide(playerid);
				}
				Inventory_ActionDestroy(playerid);
				return ~1;
			}
		}
	}
	return 1;
}
