module Tiler exposing 
    ( tile
    , Tile
    , TilingInstruction)

import Html exposing (Html)
import List

type alias Tile =
    { x: Int
    , y: Int
    }

type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , renderer: Tile -> Html a
    }

tile : TilingInstruction a -> Html a
tile instruction = 
    Html.div [] (List.map (row instruction.renderer) (rows instruction))

row : (Tile -> Html a) -> List Tile -> Html a
row renderer tiles =
    Html.div [] (List.map renderer tiles)

rows : TilingInstruction a -> List (List Tile)
rows instruction =
    let rowRange = range instruction.origin.y instruction.rowCount
        columnRange = range instruction.origin.x instruction.columnCount
    in mapTwo Tile columnRange rowRange
    
range : Int -> Int -> List Int
range origin count = [origin..(origin + count - 1)]

mapTwo : (a -> b -> c) -> List a -> List b -> List (List c)
mapTwo f xs ys =
    List.map (\y -> List.map (\x -> (f x y)) xs) ys