-- suma de los divisores de n sin contar n (suma aliquota)
aliquotSum :: Int -> Int
aliquotSum n = sum [d | d <- [1..n-1], n `mod` d == 0]

-- Nicomaco: mayor=abundante, igual=perfecto, menor=deficiente
classify :: Int -> String
classify n
    | aliquotSum n > n  = "Administrative"
    | aliquotSum n == n = "Engineering"
    | otherwise         = "Humanities"

-- primeros 3 digitos = periodo (div separa año, mod separa semestre)
period :: Int -> String
period code =
    let p = code `div` 100000
    in show (p `div` 10 + 2000) ++ "-" ++ show (p `mod` 10)

-- 2 digitos centrales = categoria
category :: Int -> String
category code = classify ((code `div` 1000) `mod` 100)
-- ultimos 3 digitos = numero consecutivo de admision
admissionNumber :: Int -> String
admissionNumber code = "num" ++ show (code `mod` 1000)

-- par o impar segun el residuo de dividir entre 2
parity :: Int -> String
parity code = if code `mod` 2 == 0 then "even" else "odd"

-- codigos de periodo permitidos: 2026-2 hasta 2029-2
periodosValidos :: [Int]
periodosValidos = [262, 271, 272, 281, 282, 291, 292]
-- valida 8 digitos, periodo, categoria (01-99) y consecutivo (001-999)
codigoValido :: Int -> Bool
codigoValido code =
    code >= 10000000 && code <= 99999999 &&
    (code `div` 100000) `elem` periodosValidos &&
    let cat = (code `div` 1000) `mod` 100
        num = code `mod` 1000
    in cat >= 1 && cat <= 99 && num >= 1 && num <= 999
-- lee el codigo y muestra las 4 caracteristicas o "Invalid code"
main :: IO ()
main = do
    input <- getLine
    case reads input :: [(Int, String)] of
        [(code, "")] | codigoValido code ->
            putStrLn (period code ++ " " ++ category code ++ " "
                      ++ admissionNumber code ++ " " ++ parity code)
        _ -> putStrLn "Invalid code"
