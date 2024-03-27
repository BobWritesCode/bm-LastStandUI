

function ErrorPrint(str1, str2)
  print("^1[Error] ^2" .. tostring(str1) .. "^3" .. tostring(str2) .. "^7")
end

function DebugPrint(str)
  if Config.Debug then print("^4[Debug] ^2" .. tostring(str) .. "^7") end
end

function DebugPrint2(str1, str2)
  if Config.Debug then print("^4[Debug] ^2" .. tostring(str1) .. "^3" .. tostring(str2) .. "^7") end
end

print("^1[Bob\'s Mods] ^2AmbientHealthUI ^7- ^5Utils^7")
