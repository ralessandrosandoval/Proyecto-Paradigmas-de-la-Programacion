module Main where

import System.Directory (doesFileExist)
import Data.Char (isSpace)

data RegistroCurso = RegistroCurso { estudiante :: String, codigoCurso :: String, nota :: Double } deriving (Show)

mapear :: (a -> b) -> [a] -> [b]
mapear _ [] = []
mapear f (x:xs) = f x : mapear f xs

filtrar :: (a -> Bool) -> [a] -> [a]
filtrar _ [] = []
filtrar p (x:xs) = if p x then x : filtrar p xs else filtrar p xs

reducir :: (b -> a -> b) -> b -> [a] -> b
reducir _ acc [] = acc
reducir f acc (x:xs) = reducir f (f acc x) xs

intercalar :: String -> [String] -> String
intercalar _ [] = ""
intercalar _ [x] = x
intercalar sep (x:xs) = x ++ sep ++ intercalar sep xs

unirLineas :: [String] -> String
unirLineas = intercalar "\n"

pertenece :: Eq a => a -> [a] -> Bool
pertenece _ [] = False
pertenece y (x:xs) = if x == y then True else pertenece y xs

mapearMaybeLista :: (a -> Maybe b) -> [a] -> [b]
mapearMaybeLista _ [] = []
mapearMaybeLista f (x:xs) = convertirMaybe (f x) ++ mapearMaybeLista f xs
  where
    convertirMaybe (Just z) = [z]
    convertirMaybe Nothing  = []

recortar :: String -> String
recortar = f . f
  where f = reverse . dropWhile isSpace


dividirPorComas :: String -> [String]
dividirPorComas [] = []
dividirPorComas s =
  let (a, resto) = break (==',') s
  in dividir a resto
  where
    dividir a []      = [a]
    dividir a (_:rs)  = a : dividirPorComas rs

leerDoubleSeguro :: String -> Maybe Double
leerDoubleSeguro s = leer (reads s :: [(Double, String)])
  where
    leer [(d, _)] = Just d
    leer _        = Nothing

parsearRegistro :: String -> Maybe RegistroCurso
parsearRegistro line =
  let partes = mapear recortar (dividirPorComas line)
  in parsear partes
  where
    parsear (codigo:g:[])      = leerDoubleSeguro g >>= \d -> Just (RegistroCurso "" codigo d)
    parsear (est:codigo:g:_)   = leerDoubleSeguro g >>= \d -> Just (RegistroCurso est codigo d)
    parsear _                  = Nothing


parsearCSV :: String -> [RegistroCurso]
parsearCSV content =
  case lines content of
    [] -> []
    (primera:resto) ->
      let esCabecera = primera == "estudiante,codigoCurso,nota"
          lineasAProcesar = if esCabecera then resto else primera : resto
          registrosLimpios = filtrar (\linea -> not (null (recortar linea))) lineasAProcesar
      in mapearMaybeLista parsearRegistro registrosLimpios

promedio :: [RegistroCurso] -> Double
promedio rs =
  let (total, count) = reducir (\(sumNotas, num) r -> (sumNotas + nota r, num + 1)) (0, 0) rs
  in if count == 0
       then 0
       else total / fromIntegral count

cursosAprobados :: [RegistroCurso] -> [String]
cursosAprobados = mapear codigoCurso . filtrar (\r -> nota r >= 11)

cursosDesaprobados :: [RegistroCurso] -> [String]
cursosDesaprobados = mapear codigoCurso . filtrar (\r -> nota r < 11)

clasificarRendimiento :: Double -> String
clasificarRendimiento p
  | p >= 16   = "Alto"
  | p >= 13   = "Medio"
  | otherwise = "Bajo"

recomendacion :: Double -> String
recomendacion p
  | p >= 16   = "El estudiante tiene buen rendimiento. Puede llevar cursos de mayor dificultad."
  | p >= 13   = "El estudiante tiene rendimiento medio. Mantener esfuerzo y profundizar contenidos."
  | otherwise = "Se recomienda reforzar cursos base antes de llevar cursos avanzados."

conteos :: [RegistroCurso] -> (Int, Int)
conteos rs = reducir (\(a, d) r -> if nota r >= 11 then (a + 1, d) else (a, d + 1)) (0, 0) rs

mostrarLista :: [String] -> String
mostrarLista [] = "Ninguno"
mostrarLista xs = intercalar ", " xs

estudiantesUnicos :: [RegistroCurso] -> [String]
estudiantesUnicos [] = []
estudiantesUnicos (r:rs) =
  let resto = estudiantesUnicos rs
  in if pertenece (estudiante r) resto
       then resto
       else estudiante r : resto

resumenTodos :: [RegistroCurso] -> String
resumenTodos registros =
  let estudiantes = estudiantesUnicos registros
      res = mapear (\est -> resumen est (filtrar (\r -> estudiante r == est) registros)) estudiantes
  in if null res then "Sin registros" else intercalar "\n\n" res

resumen :: String -> [RegistroCurso] -> String
resumen estudiante rs =
  let prom = promedio rs
      apro = cursosAprobados rs
      des = cursosDesaprobados rs
      rend = clasificarRendimiento prom
      rec = recomendacion prom
      (aCount, dCount) = conteos rs
  in unirLineas [ "Estudiante: " ++ estudiante
                 , "Promedio: " ++ show (redondear1 prom)
                 , "Cursos aprobados: " ++ mostrarLista apro
                 , "Cursos desaprobados: " ++ mostrarLista des
                 , "Rendimiento: " ++ rend
                 , "Recomendacion: " ++ rec
                 , "Conteo aprobados: " ++ show aCount ++ ", desaprobados: " ++ show dCount
                 ]

redondear1 :: Double -> Double
redondear1 x = fromIntegral (round (x * 10)) / 10

main :: IO ()
main = do
  let fileName = "historial.csv"
  exists <- doesFileExist fileName
  if not exists
    then putStrLn $ "Error: no se encontró el archivo '" ++ fileName ++ "'. Coloca un CSV con ese nombre en el directorio actual."
    else do
      content <- readFile fileName
      let registros = parsearCSV content
      putStrLn (resumenTodos registros)