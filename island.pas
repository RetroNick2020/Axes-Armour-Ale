(* Stores the overworld map and provides helper functions *)

unit island;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, overworld;

type
  overworldTerrain = (tSea, tForest, tPlains, tLocation);

type
  (* Tiles that make up the overworld *)
  overworldTile = record
    (* Unique tile ID *)
    id: smallint;
    (* Does the tile block movement *)
    Blocks: boolean;
    (* Does the tile contain a dungeon *)
    Occupied: boolean;
    (* Has the tile been discovered already *)
    Discovered: boolean;
    (* Type of terrain *)
    TerrainType: overworldTerrain;
    (* Character used to represent the tile *)
    Glyph: shortstring;
    (* Colour of the glyph *)
    GlyphColour: shortstring;
  end;

type
  (* Visible tiles that display the overworld *)
  displayTile = record
    (* Character used to represent the tile *)
    Glyph: shortstring;
    (* Colour of the tile *)
    GlyphColour: shortstring;
  end;

type
  (* Location on the island *)
  locationTile = record
    (* coordinates *)
    X, Y: smallint;
    (* Name of location *)
    name: shortstring;
  end;

var
  (* The overworld map data *)
  overworldMap: array[1..overworld.MAXR, 1..overworld.MAXC] of overworldTile;
  (* The overworld map that the camera uses *)
  overworldDisplay: array[1..overworld.MAXR, 1..overworld.MAXC] of displayTile;
  (* List of locations on the island *)
  locationLookup: array of locationTile;

(* Store the newly generated island in memory *)
procedure storeEllanToll;
(* Draw a tile on the map *)
procedure drawOWTile(c, r: smallint);
(* Return the name of the location on the map *)
function getLocationName(xPOS, yPOS: smallint):shortstring;


implementation

procedure storeEllanToll;
var
  r, c, id_int: smallint;
begin
  r := 1;
  c := 1;
  id_int := 0;
  for r := 1 to overworld.MAXR do
  begin
    for c := 1 to overworld.MAXC do
    begin
      Inc(id_int);
      with overworldMap[r][c] do
      begin
        id := id_int;
        { Forest }
        if (overworld.terrainArray[r][c] = 'A') then
        begin
          Glyph := chr(6);
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'B') then
        begin
          Glyph := chr(6);
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'C') then
        begin
          Glyph := chr(5);
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'D') then
        begin
          Glyph := '"';
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'E') then
        begin
          Glyph := '''';
          TerrainType := tForest;
          GlyphColour := 'green';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'F') then
        begin
          Glyph := '"';
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'G') then
        begin
          Glyph := '''';
          TerrainType := tForest;
          GlyphColour := 'lightGreen';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        { Sea }
        else if (overworld.terrainArray[r][c] = '~') then
        begin
          Glyph := chr(247);
          TerrainType := tSea;
          GlyphColour := 'blue';
          Blocks := True;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = '-') then
        begin
          Glyph := '~';
          TerrainType := tSea;
          GlyphColour := 'lightBlue';
          Blocks := True;
          Occupied := False;
          Discovered := False;
        end
        { Plains }
        else if (overworld.terrainArray[r][c] = 'H') then
        begin
          Glyph := '.';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'I') then
        begin
          Glyph := ',';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'J') then
        begin
          Glyph := '.';
          TerrainType := tPlains;
          GlyphColour := 'yellow';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'K') then
        begin
          Glyph := chr(94);
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'L') then
        begin
          Glyph := ':';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'M') then
        begin
          Glyph := ';';
          TerrainType := tPlains;
          GlyphColour := 'brown';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = 'N') then
        begin
          Glyph := ':';
          TerrainType := tPlains;
          GlyphColour := 'yellow';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end
        else if (overworld.terrainArray[r][c] = '>') then
        begin
          Glyph := '>';
          TerrainType := tLocation;
          GlyphColour := 'white';
          Blocks := False;
          Occupied := False;
          Discovered := False;
        end;
      end;
    end;
  end;
  (* Setup 'display map' *)
  for r := 1 to overworld.MAXR do
  begin
    for c := 1 to overworld.MAXC do
    begin
      overworldDisplay[r][c].Glyph := ' ';
      overworldDisplay[r][c].GlyphColour := 'black';
    end;
  end;
end;

procedure drawOWTile(c, r: smallint);
begin
  if (overworldMap[r][c].Discovered = True) then
  begin
    overworldDisplay[r][c].Glyph := overworldMap[r][c].Glyph;
    overworldDisplay[r][c].GlyphColour := overworldMap[r][c].GlyphColour;
  end
  else
  begin
    overworldDisplay[r][c].Glyph := ' ';
    overworldDisplay[r][c].GlyphColour := 'black';
  end;
end;

function getLocationName(xPOS, yPOS: smallint): shortstring;
var
  i: smallint;
begin
  Result := '';
    for i := 0 to High(locationLookup) do
  begin
    if (locationLookup[i].X = xPOS) and (locationLookup[i].Y = yPOS) then
    begin
      Result := locationLookup[i].name;
      exit;
    end;
  end;
end;

end.
