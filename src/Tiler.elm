module Tiler exposing 
    ( tile
    , newTile
    , fold
    , TileSpec
    , Tile
    , TilingInstruction)

import Html exposing (Html, Attribute)
import List

type Tile =
    ValidTile Int Int Int

type alias TileSpec =
    { x: Int
    , y: Int
    , zoom: Int
    }

type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , viewTile: Tile -> Html a
    , viewRow: List (Html a) -> Html a
    , outerAttributes: List (Attribute a)
    }

newTile : TileSpec -> Tile
newTile tileSpec =
    let wrap z c = c % (2 ^ z)
    in ValidTile (wrap tileSpec.zoom tileSpec.x) tileSpec.y tileSpec.zoom

tile : TilingInstruction a -> Html a
tile instruction = 
    Html.div instruction.outerAttributes (List.map (viewRow instruction) (rows instruction))

fold : Tile -> (Int -> Int -> Int -> a) -> a
fold t f =
    case t of ValidTile x y z -> f x y z

viewRow : TilingInstruction a -> List Tile -> Html a
viewRow ti tiles =
     ti.viewRow (List.map ti.viewTile tiles)

rows : TilingInstruction a -> List (List Tile)
rows instruction =
    let tx = case instruction.origin of ValidTile x y z -> x
        ty = case instruction.origin of ValidTile x y z -> y
        rowRange = range ty instruction.rowCount
        columnRange = range tx instruction.columnCount
        t = \x y -> newTile (TileSpec x y (case instruction.origin of ValidTile x y z -> z))
    in mapTwo t columnRange rowRange
    
range : Int -> Int -> List Int
range origin count = [origin..(origin + count - 1)]

mapTwo : (a -> b -> c) -> List a -> List b -> List (List c)
mapTwo f xs ys =
    List.map (\y -> List.map (\x -> (f x y)) xs) ys