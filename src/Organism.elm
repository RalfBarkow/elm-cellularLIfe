module Organism exposing (Organism(..), setAge
   , distance, populationDensityAtOrganism, maximumPopulationDensity
   ,  color,age, id, displace, readyToDivide, species
   , tick, readyToDie, grow,minArea, position, setPosition ,setArea, setId)

import CellGrid exposing(Position)
import Color exposing(Color)
import Species exposing(Species(..), SpeciesName(..))
import EngineData exposing(config)
import Utility

type Organism =
  Organism OrganismData

type alias OrganismData =
    {
         id : Int
       , species : Species
       , diameter : Float
       , area : Float
       , numberOfCells : Int
       , position : Position
       , age : Int
      }

{-|
    import State exposing(monoSeed)

    distance 6 5 monoSeed
    --> 1
-}
distance : Int -> Int -> Organism -> Float
distance i j (Organism data) =
    let
       p = data.position
       dx = p.row - i |> toFloat
       dy = p.column - j |> toFloat
    in
       sqrt (dx*dx + dy*dy)

tick : Organism -> Organism
tick  organism =
    map (\data -> {data | age = data.age  + 1}) organism

{-|

    import State exposing(monoSeed)

    o2 : Organism
    o2 = displace 1 0 monoSeed

    populationDensityAtOrganism 1 monoSeed [monoSeed] |> String.fromFloat
    --> "0.1111"

    populationDensityAtOrganism 2 monoSeed [monoSeed, o2] |> String.fromFloat
    --> "0.08"

-}
populationDensityAtOrganism : Float -> Organism -> List Organism -> Float
populationDensityAtOrganism d o list =
    let
        p = position o
    in
      populationDensity p.row p.column d list

maximumPopulationDensity  : Float -> List Organism -> Float
maximumPopulationDensity d list =
    List.map (\o -> populationDensityAtOrganism d o list) list
      |> List.maximum
      |> Maybe.withDefault 0

populationDensity : Int -> Int -> Float -> List Organism -> Float
populationDensity i j d list =
    let
       numberOfNeighbors = List.filter (\o -> distance i j o < d) list |> List.length |> toFloat
       width = 2 * d + 1
       area_ = width * width
    in
       numberOfNeighbors / area_ |> Utility.roundTo 4

age : Organism -> Int
age (Organism data) =
    data.age

displace : Int -> Int -> Organism -> Organism
displace dx dy organism =
    let
       p = position organism
       r = p.row  + dx |> clampX
       c = p.column + dy |> clampY
    in
      setPosition r c organism


clampX : Int -> Int
clampX = clamp 0  config.gridWidth

clampY : Int -> Int
clampY = clamp 0  config.gridWidth

id : Organism  -> Int
id (Organism data) =
    data.id

setId : Int -> Organism -> Organism
setId k organism  =
    map (\data -> { data | id = k} ) organism

grow : Organism -> Organism
grow organism =
    let
        r = growthRate organism
        a = Species.minArea (species organism)
        b = Species.maxArea (species organism)

        newArea = clamp a b ((1.0 + r) * (area organism))
        newDiameter = sqrt newArea

    in
        map (\data -> {data | area = newArea, diameter = newDiameter} ) organism

readyToDivide : Organism -> Bool
readyToDivide (Organism data) =
    data.area > 0.50 * (Species.maxArea data.species) && data.area <=  0.95 * (Species.maxArea data.species)

readyToDie : Organism -> Bool
readyToDie (Organism data) =
    data.age > (Species.lifeSpan data.species)


map : (OrganismData -> OrganismData) -> Organism -> Organism
map f (Organism data) =
    Organism (f data)


diameter : Organism -> Float
diameter  (Organism data) = data.diameter

area : Organism -> Float
area  (Organism data) = data.area

minArea : Organism -> Float
minArea  (Organism data) = Species.minArea  data.species

growthRate : Organism -> Float
growthRate organism = Species.growthRate (species organism)

color : Organism  -> Color
color organism =
  let
     ageFraction = (age organism |> toFloat) / (Species.lifeSpan (species organism) |> toFloat)
  in
   if ageFraction < 0.02 then
     Color.rgb 0 1 0
   else if ageFraction < 0.3 then
     let
        x = ageFraction + 0.8
      in
      Color.rgb x x 0
   else if ageFraction < 0.8 then
      let
         y = (ageFraction - 0.3)/0.5
         yy = (1 - y)
      in
      Color.rgb y y yy
   else
      let
         z = (ageFraction - 0.8)/0.8
         zz = 1 - z
      in
      Color.rgb (0.5*z) zz zz

position : Organism -> Position
position (Organism data) = data.position



setPosition : Int -> Int -> Organism -> Organism
setPosition i j organism =
    map (\r -> {r | position =  {row = i, column = j}}) organism

setArea : Float -> Organism -> Organism
setArea a organism  =
   map (\r -> {r | area =  a}) organism

setAge: Int -> Organism -> Organism
setAge n organism  =
   map (\r -> {r | age =  n}) organism

species : Organism -> Species
species (Organism data) = data.species

