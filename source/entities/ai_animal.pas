(* Shared Artificial Stupidity unit for animal AI *)

unit ai_animal;

{$mode fpc}{$H+}

interface

uses
  SysUtils, Math;

(* Move in a random direction *)
procedure wander(id, spx, spy: smallint);
(* Chase the player character *)
procedure chasePlayer(id, spx, spy: smallint);
(* Run away from the player character *)
procedure escapePlayer(id, spx, spy: smallint);
(* NPC attacks the player *)
procedure combat(id: smallint);
(* NPC attacks another entity *)
procedure infighting(npcID, enemyID: smallint);

implementation

uses
  entities, map, ui, combat_resolver, globalUtils;

procedure wander(id, spx, spy: smallint);
var
  direction, attempts, testx, testy: smallint;
begin
  { Set NPC state }
  entityList[id].state := stateNeutral;
  attempts := 0;
  testx := 0;
  testy := 0;
  direction := 0;
  repeat
    (* Reset values after each failed loop so they don't keep dec/incrementing *)
    testx := spx;
    testy := spy;
    direction := random(6);
    (* limit the number of attempts to move so the game doesn't hang if NPC is stuck *)
    Inc(attempts);
    if attempts > 10 then
    begin
      entities.moveNPC(id, spx, spy);
      exit;
    end;
    case direction of
      0: Dec(testy);
      1: Inc(testy);
      2: Dec(testx);
      3: Inc(testx);
      4: testx := spx;
      5: testy := spy;
    end
  until (map.canMove(testx, testy) = True) and (map.isOccupied(testx, testy) = False);
  entities.moveNPC(id, testx, testy);
end;

procedure chasePlayer(id, spx, spy: smallint);
var
  newX, newY, dx, dy: smallint;
  distance: double;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to chase the player *)
  dx := entityList[0].posX - spx;
  dy := entityList[0].posY - spy;
  if (dx = 0) and (dy = 0) then
  begin
    newX := spx;
    newy := spy;
  end
  else
  begin
    distance := sqrt(dx ** 2 + dy ** 2);
    dx := round(dx / distance);
    dy := round(dy / distance);
    newX := spx + dx;
    newY := spy + dy;
  end;
  (* New coordinates set. Check if they are walkable *)
  if (map.canMove(newX, newY) = True) then
  begin
    (* Do they contain the player *)
    if (map.hasPlayer(newX, newY) = True) then
    begin
      (* Remain on original tile and attack *)
      entities.moveNPC(id, spx, spy);
      combat(id);
    end
    (* Else if tile does not contain player, check for another entity *)
    else if (map.isOccupied(newX, newY) = True) then
    begin
      if (entityList[entities.getCreatureID(newX, newY)].race <> entityList[id].race) then
      begin
        infighting(id, getCreatureID(newX, newY));
        entities.moveNPC(id, spx, spy);
      end
      else
      begin
        (* If the entity is another animal, the NPC doesn't attack *)
        ui.bufferMessage('The ' + entityList[id].race + ' bumps into ' + getCreatureName(newX, newY));
        entities.moveNPC(id, spx, spy);
      end;
    end
    (* if map is unoccupied, move to that tile *)
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    ai_animal.wander(id, spx, spy);
end;

procedure escapePlayer(id, spx, spy: smallint);
var
  newX, newY, dx, dy: smallint;
  distance: single;
begin
  newX := 0;
  newY := 0;
  (* Get new coordinates to escape the player *)
  dx := entityList[0].posX - spx;
  dy := entityList[0].posY - spy;
  if (dx = 0) and (dy = 0) then
  begin
    newX := spx;
    newy := spy;
  end
  else
  begin
    distance := sqrt(dx ** 2 + dy ** 2);
    dx := round(dx / distance);
    dy := round(dy / distance);
    if (dx > 0) then
      dx := -1;
    if (dx < 0) then
      dx := 1;
    dy := round(dy / distance);
    if (dy > 0) then
      dy := -1;
    if (dy < 0) then
      dy := 1;
    newX := spx + dx;
    newY := spy + dy;
  end;
  if (map.canMove(newX, newY) = True) then
  begin
    if (map.hasPlayer(newX, newY) = True) then
    begin
      entities.moveNPC(id, spx, spy);
      combat(id);
    end
    else if (map.isOccupied(newX, newY) = False) then
      entities.moveNPC(id, newX, newY);
  end
  else
    ai_animal.wander(id, spx, spy);
end;

procedure combat(id: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entities.entityList[id].attack) - entities.entityList[0].defence;
  if (damageAmount > 0) then
  begin
    entities.entityList[0].currentHP := (entities.entityList[0].currentHP - damageAmount);
    if (entities.entityList[0].currentHP < 1) then
    begin
      killer := 'a ' + entityList[id].race;
      exit;
    end
    else
    begin
      if (damageAmount = 1) then
        ui.displayMessage('The ' + entityList[id].race + ' slightly wounds you')
      else
        begin
             ui.displayMessage('The ' + entityList[id].race + ' bites you, inflicting ' + IntToStr(damageAmount) + ' damage');
             if (entityList[id].intName = 'Matango') then
             begin
               (* Fungus does poison damage *)
               entityList[0].stsPoison := True;
               entityList[0].tmrPoison := damageAmount + 4;
               if (killer = 'empty') then
                  killer := 'an infected mushroom person';
             end
             else if (entityList[id].intName = 'smlCorpseSpider') then
             begin
               (* Corpse Spider does poison damage *)
               entityList[0].stsPoison := True;
               entityList[0].tmrPoison := damageAmount + 2;
               if (killer = 'empty') then
                  killer := 'a small Corpse Spider';
             end
             else if (entityList[id].intName = 'embalmSpider') then
             begin
               (* Embalming Spider does poison damage *)
               entityList[0].stsPoison := True;
               entityList[0].tmrPoison := damageAmount + 3;
               if (killer = 'empty') then
                  killer := 'an Embalming Spider';
             end;
        end;
      (* Update health display to show damage *)
      ui.updateHealth;
    end;
  end
  else
  begin
    ui.displayMessage('The ' + entityList[id].race + ' attacks but misses');
    combat_resolver.spiteDMG(id);
  end;
end;

procedure infighting(npcID, enemyID: smallint);
var
  damageAmount: smallint;
begin
  damageAmount := globalutils.randomRange(1, entityList[npcID].attack) - entityList[enemyID].defence;
   if (damageAmount > 0) then
   begin
     entityList[enemyID].currentHP := (entityList[enemyID].currentHP - damageAmount);
     if (entities.entityList[enemyID].currentHP < 1) then
     begin
          killEntity(enemyID);
          ui.displayMessage('The ' + entityList[npcID].race + ' kills the ' + entityList[enemyID].race);
     end
     else
         ui.displayMessage('The ' + entityList[npcID].race + ' attacks the ' + entityList[enemyID].race);
   end;
end;

end.
