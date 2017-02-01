module FixedViewport exposing 
    ( Requirements
    , Dimensions
    , calculateDimensions)

import Locator exposing (LatLn, TileAddress, lookup)
import Tiler exposing (Tile)

type alias Requirements = 
    { centre: LatLn
    , zoom: Int
    , tileSize: Int
    , width: Int
    , height: Int
    }

type alias Dimensions =
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , height: Int
    , width: Int
    , top: Int
    , left: Int
    , zoom: Int
    , tileSize: Int
    }
    
calculateDimensions : Requirements -> Dimensions
calculateDimensions requirements =
    let (columnCount, rowCount) = calculateTileCount requirements
        tileAddress = lookup requirements.zoom requirements.centre
        (centreTx, centreTy) = tileAddress.tile
        (left, top) = calculateOffsets requirements (columnCount, rowCount) tileAddress.pixelWithinTile
        origin = 
            Tiler.newTile (Tiler.TileSpec (centreTx - (columnCount // 2)) (centreTy - (rowCount // 2)) requirements.zoom)
    in
      { rowCount = rowCount
      , columnCount = columnCount
      , height = requirements.height
      , width = requirements.width
      , top = top
      , left = left
      , origin = origin
      , zoom = requirements.zoom
      , tileSize = requirements.tileSize
      } 

calculateTileCount : Requirements -> (Int, Int)
calculateTileCount requirements =
    ( (requirements.width // requirements.tileSize) + 3
    , (requirements.height // requirements.tileSize) + 3
    )

calculateOffsets : Requirements -> (Int, Int) -> (Int, Int) -> (Int, Int)
calculateOffsets requirements (columnCount, rowCount) (xpixel, ypixel) =
    let xoff = (columnCount // 2) * requirements.tileSize
        yoff = (rowCount // 2) * requirements.tileSize
    in
    ( (requirements.width // 2) - (xoff + xpixel)
    , (requirements.height // 2) - (yoff + ypixel)
    )