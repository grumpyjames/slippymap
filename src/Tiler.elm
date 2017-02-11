module Tiler exposing 
    ( tile
    , newTile
    , fold
    , TileSpec
    , Tile
    , TilingInstruction)

import Html exposing (Html, Attribute)
import List
 
type Tile 
    = ValidTile Int Int Int
    | OutOfBounds

type alias TileSpec =
    { x: Int
    , y: Int
    , zoom: Int
    }

type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: TileSpec
    , viewTile: Tile -> Html a
    , viewRow: List (Html a) -> Html a
    , outerAttributes: List (Attribute a)
    }

newTile : TileSpec -> Tile
newTile tileSpec =
    let maxTile = (2 ^ tileSpec.zoom)
        wrap z c = c % maxTile
        withinBounds = (tileSpec.y >= 0) && (tileSpec.y < maxTile)  
    in 
      if withinBounds 
      then ValidTile (wrap tileSpec.zoom tileSpec.x) tileSpec.y tileSpec.zoom
      else OutOfBounds

tile : TilingInstruction a -> Html a
tile instruction = 
    Html.div instruction.outerAttributes (List.map (viewRow instruction) (rows instruction))

fold : Tile -> (Int -> Int -> Int -> a) -> a -> a
fold t f default =
    case t of 
      ValidTile x y z -> f x y z
      OutOfBounds -> default

viewRow : TilingInstruction a -> List Tile -> Html a
viewRow ti tiles =
     ti.viewRow (List.map ti.viewTile tiles)

rows : TilingInstruction a -> List (List Tile)
rows instruction =
    let rowRange = range instruction.origin.y instruction.rowCount
        columnRange = range instruction.origin.x instruction.columnCount
        -- horrible wrangling to get zoom here
        t x y = 
            newTile (TileSpec x y instruction.origin.zoom)
    in mapTwo t columnRange rowRange
    
range : Int -> Int -> List Int
range origin count = [origin..(origin + count - 1)]

mapTwo : (a -> b -> c) -> List a -> List b -> List (List c)
mapTwo f xs ys =
    List.map (\y -> List.map (\x -> (f x y)) xs) ys