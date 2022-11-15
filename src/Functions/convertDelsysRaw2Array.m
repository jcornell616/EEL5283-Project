function arr = convertDelsysRaw2Array(RawData, StartIdx, EndIdx)
arr = table2array(rmmissing(RawData(:, StartIdx:EndIdx)));
end