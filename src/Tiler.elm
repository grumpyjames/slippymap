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
    , viewTile: Tile -> Html a
    , viewRow: List (Html a) -> Html a
    }

tile : TilingInstruction a -> Html a
tile instruction = 
    Html.div [] (List.map (viewRow instruction) (rows instruction))

viewRow : TilingInstruction a -> List Tile -> Html a
viewRow ti tiles =
     ti.viewRow (List.map ti.viewTile tiles)

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