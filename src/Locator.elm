module Locator exposing (LatLn, TileAddress, lookup)

type alias LatLn =
    { latitude: Float
    , longitude: Float
    }

type alias TileAddress =
    { tile: (Int, Int)
    , pixelWithinTile: (Int, Int)
    }

lookup : Int -> LatLn -> TileAddress
lookup zoom latln = 
    let zoomAsFloat = toFloat zoom
        (xTile, xPixel) = address <| lon2tilex zoomAsFloat latln.longitude
        (yTile, yPixel) = address <| lat2tiley zoomAsFloat latln.latitude
    in TileAddress (xTile, yTile) (xPixel, yPixel)

tileSize = 256

address : Float -> (Int, Int)
address tileFloat =
    let tileIndex = floor tileFloat
        pixel = floor <| tileSize * (tileFloat - (toFloat tileIndex))
    in (tileIndex, pixel)

log = logBase e

lon2tilex : Float -> Float -> Float
lon2tilex zoom lon = 
    (lon + 180.0) / 360.0 * (2.0 ^ (toFloat (floor zoom))) 

lat2tiley : Float -> Float -> Float
lat2tiley zoom lat = 
    (1.0 - log( tan(lat * pi/180.0) + 1.0 / cos(lat * pi/180.0)) / pi) / 2.0 * (2.0 ^ (toFloat (floor zoom)))